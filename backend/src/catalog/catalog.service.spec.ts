import { Test, TestingModule } from '@nestjs/testing';
import { getModelToken } from '@nestjs/mongoose';
import { NotFoundException, ConflictException, BadRequestException } from '@nestjs/common';
import { CatalogService } from './catalog.service';
import { Product } from './schemas/product.schema';
import { Category } from './schemas/category.schema';
import { Merchant } from './schemas/merchant.schema';
import { BillingService } from '../billing/billing.service';

describe('CatalogService', () => {
  let service: CatalogService;
  let mockProductModel: any;
  let mockCategoryModel: any;
  let mockMerchantModel: any;
  let mockBillingService: any;

  beforeEach(async () => {
    mockProductModel = {
      find: jest.fn().mockReturnThis(),
      findById: jest.fn().mockReturnThis(),
      findByIdAndUpdate: jest.fn().mockReturnThis(),
      findByIdAndDelete: jest.fn().mockReturnThis(),
      countDocuments: jest.fn(),
      sort: jest.fn().mockReturnThis(),
      populate: jest.fn().mockReturnThis(),
      limit: jest.fn().mockReturnThis(),
      exec: jest.fn(),
    };

    mockCategoryModel = {
      find: jest.fn().mockReturnThis(),
      findOne: jest.fn().mockReturnThis(),
      findById: jest.fn().mockReturnThis(),
      findByIdAndUpdate: jest.fn().mockReturnThis(),
      findByIdAndDelete: jest.fn().mockReturnThis(),
      exec: jest.fn(),
    };

    // Mock constructor
    mockProductModel.prototype = {};
    mockCategoryModel.prototype = {};

    mockMerchantModel = {
      find: jest.fn().mockReturnThis(),
      select: jest.fn().mockReturnThis(),
      sort: jest.fn().mockReturnThis(),
      lean: jest.fn().mockReturnThis(),
      exec: jest.fn(),
    };

    mockBillingService = {
      assertMerchantAccessOrThrow: jest.fn(),
      getEntitlementsForUser: jest.fn(),
      resolveMerchantIdForUser: jest.fn(),
    };

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        CatalogService,
        {
          provide: getModelToken(Product.name),
          useValue: mockProductModel,
        },
        {
          provide: getModelToken(Category.name),
          useValue: mockCategoryModel,
        },
        {
          provide: getModelToken(Merchant.name),
          useValue: mockMerchantModel,
        },
        {
          provide: BillingService,
          useValue: mockBillingService,
        },
      ],
    }).compile();

    service = module.get<CatalogService>(CatalogService);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  describe('createProduct', () => {
    it('should create a new product with valid data', async () => {
      const dto = {
        name: 'Harissa Spicy',
        description: 'Premium harissa paste',
        price: 15,
        stock: 100,
        merchantId: '507f1f77bcf86cd799439011',
        categoryIds: ['507f1f77bcf86cd799439012'],
        tags: ['spicy', 'condiment'],
        images: ['harissa.jpg'],
        relatedProductIds: [],
        regions: ['tunis'],
        isActive: true,
      };

      const saveMock = jest.fn().mockResolvedValue(dto);
      const ProductConstructor = jest.fn().mockImplementation(() => ({
        save: saveMock,
      }));
      (service as any).productModel = ProductConstructor;

      await service.createProduct(dto);
      expect(ProductConstructor).toHaveBeenCalled();
      expect(saveMock).toHaveBeenCalled();
    });

    it('should enforce merchant.products.max for merchant requesters', async () => {
      const dto = {
        name: 'Harissa Spicy',
        price: 15,
        stock: 100,
        merchantId: '507f1f77bcf86cd799439011',
      } as any;

      mockBillingService.getEntitlementsForUser.mockResolvedValue({
        merchant: { limits: { 'merchant.products.max': 1 } },
      });
      mockProductModel.countDocuments.mockResolvedValue(1);

      await expect(
        service.createProduct(dto, { userId: 'u1', role: 'MERCHANT' }),
      ).rejects.toThrow('Plan limit reached');
    });
  });

  describe('updateProduct', () => {
    it('should update an existing product', async () => {
      const id = '507f1f77bcf86cd799439011';
      const dto = { name: 'Updated Harissa', price: 18 };
      const updatedProduct = { _id: id, ...dto };

      mockProductModel.findByIdAndUpdate.mockReturnThis();
      mockProductModel.exec.mockResolvedValue(updatedProduct);

      const result = await service.updateProduct(id, dto);
      expect(result).toEqual(updatedProduct);
      expect(mockProductModel.findByIdAndUpdate).toHaveBeenCalledWith(id, dto, { new: true });
    });

    it('should throw NotFoundException when product not found', async () => {
      const id = 'nonexistent-id';
      mockProductModel.findByIdAndUpdate.mockReturnThis();
      mockProductModel.exec.mockResolvedValue(null);

      await expect(service.updateProduct(id, { name: 'Test' })).rejects.toThrow(NotFoundException);
    });
  });

  describe('deleteProduct', () => {
    it('should delete an existing product', async () => {
      const id = '507f1f77bcf86cd799439011';
      mockProductModel.findByIdAndDelete.mockReturnThis();
      mockProductModel.exec.mockResolvedValue({ _id: id });

      await service.deleteProduct(id);
      expect(mockProductModel.findByIdAndDelete).toHaveBeenCalledWith(id);
    });

    it('should throw NotFoundException when product not found', async () => {
      const id = 'nonexistent-id';
      mockProductModel.findByIdAndDelete.mockReturnThis();
      mockProductModel.exec.mockResolvedValue(null);

      await expect(service.deleteProduct(id)).rejects.toThrow(NotFoundException);
    });
  });

  describe('createCategory', () => {
    it('should create a new category with unique slug', async () => {
      const dto = { name: 'Condiments', slug: 'condiments', isActive: true };

      const saveMock = jest.fn().mockResolvedValue(dto);
      const CategoryConstructor: any = jest.fn().mockImplementation(() => ({
        save: saveMock,
      }));

      // Set up findOne to return null (no existing category)
      CategoryConstructor.findOne = jest.fn().mockReturnValue({
        exec: jest.fn().mockResolvedValue(null),
      });

      (service as any).categoryModel = CategoryConstructor;

      await service.createCategory(dto);
      expect(CategoryConstructor.findOne).toHaveBeenCalledWith({ slug: dto.slug });
      expect(CategoryConstructor).toHaveBeenCalled();
      expect(saveMock).toHaveBeenCalled();
    });

    it('should throw ConflictException when slug already exists', async () => {
      const dto = { name: 'Condiments', slug: 'condiments', isActive: true };
      const CategoryConstructor: any = {};
      CategoryConstructor.findOne = jest.fn().mockReturnValue({
        exec: jest.fn().mockResolvedValue({ _id: 'existing-id', slug: 'condiments' }),
      });
      (service as any).categoryModel = CategoryConstructor;

      await expect(service.createCategory(dto)).rejects.toThrow(ConflictException);
    });
  });

  describe('updateCategory', () => {
    it('should update an existing category', async () => {
      const id = '507f1f77bcf86cd799439011';
      const dto = { name: 'Updated Condiments' };
      const updatedCategory = { _id: id, ...dto };

      mockCategoryModel.findByIdAndUpdate.mockReturnThis();
      mockCategoryModel.exec.mockResolvedValue(updatedCategory);

      const result = await service.updateCategory(id, dto);
      expect(result).toEqual(updatedCategory);
    });

    it('should throw ConflictException when new slug already exists', async () => {
      const id = '507f1f77bcf86cd799439011';
      const dto = { slug: 'existing-slug' };

      mockCategoryModel.findOne.mockReturnThis();
      mockCategoryModel.exec.mockResolvedValue({ _id: 'other-id', slug: 'existing-slug' });

      await expect(service.updateCategory(id, dto)).rejects.toThrow(ConflictException);
    });

    it('should throw NotFoundException when category not found', async () => {
      const id = 'nonexistent-id';
      mockCategoryModel.findOne.mockReturnThis();
      mockCategoryModel.exec.mockResolvedValue(null);
      mockCategoryModel.findByIdAndUpdate.mockReturnThis();
      mockCategoryModel.exec.mockResolvedValue(null);

      await expect(service.updateCategory(id, { name: 'Test' })).rejects.toThrow(NotFoundException);
    });
  });

  describe('deleteCategory', () => {
    it('should delete an existing category', async () => {
      const id = '507f1f77bcf86cd799439011';
      mockCategoryModel.findByIdAndDelete.mockReturnThis();
      mockCategoryModel.exec.mockResolvedValue({ _id: id });

      await service.deleteCategory(id);
      expect(mockCategoryModel.findByIdAndDelete).toHaveBeenCalledWith(id);
    });

    it('should throw NotFoundException when category not found', async () => {
      const id = 'nonexistent-id';
      mockCategoryModel.findByIdAndDelete.mockReturnThis();
      mockCategoryModel.exec.mockResolvedValue(null);

      await expect(service.deleteCategory(id)).rejects.toThrow(NotFoundException);
    });
  });

  describe('listActiveMerchants', () => {
    it('should return id, name, region for active merchants', async () => {
      mockMerchantModel.exec.mockResolvedValue([
        { _id: '64a1b2c3d4e5f6789012345', name: 'Demo', region: 'TND' },
      ]);

      const result = await service.listActiveMerchants();

      expect(result).toEqual([{ id: '64a1b2c3d4e5f6789012345', name: 'Demo', region: 'TND' }]);
      expect(mockMerchantModel.find).toHaveBeenCalledWith({ isActive: true });
    });
  });

  describe('listMerchantScopedProducts', () => {
    it('merchant: resolves default merchant id and returns products', async () => {
      const mid = '507f1f77bcf86cd799439011';
      mockBillingService.resolveMerchantIdForUser.mockResolvedValue(mid);
      mockBillingService.assertMerchantAccessOrThrow.mockResolvedValue(undefined);
      const products = [{ _id: 'p1', name: 'Item' }];
      mockProductModel.exec.mockResolvedValue(products);

      const result = await service.listMerchantScopedProducts('user1', 'MERCHANT', undefined);

      expect(mockBillingService.resolveMerchantIdForUser).toHaveBeenCalledWith('user1');
      expect(mockBillingService.assertMerchantAccessOrThrow).toHaveBeenCalledWith(
        mid,
        'user1',
        'MERCHANT',
      );
      expect(result).toEqual(products);
      expect(mockProductModel.find).toHaveBeenCalled();
    });

    it('merchant: uses explicit merchantId after access check', async () => {
      const mid = '507f1f77bcf86cd799439011';
      mockBillingService.assertMerchantAccessOrThrow.mockResolvedValue(undefined);
      mockProductModel.exec.mockResolvedValue([]);

      await service.listMerchantScopedProducts('user1', 'MERCHANT', mid);

      expect(mockBillingService.resolveMerchantIdForUser).not.toHaveBeenCalled();
      expect(mockBillingService.assertMerchantAccessOrThrow).toHaveBeenCalledWith(
        mid,
        'user1',
        'MERCHANT',
      );
    });

    it('admin: requires merchantId', async () => {
      await expect(service.listMerchantScopedProducts('a1', 'ADMIN', undefined)).rejects.toThrow(
        BadRequestException,
      );
    });

    it('admin: lists products for given merchantId', async () => {
      const mid = '507f1f77bcf86cd799439011';
      mockProductModel.exec.mockResolvedValue([{ _id: 'p1' }]);

      const result = await service.listMerchantScopedProducts('a1', 'ADMIN', mid);

      expect(mockBillingService.assertMerchantAccessOrThrow).not.toHaveBeenCalled();
      expect(result).toEqual([{ _id: 'p1' }]);
    });
  });
});
