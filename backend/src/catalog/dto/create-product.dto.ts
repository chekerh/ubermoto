import {
  IsNotEmpty,
  IsString,
  IsNumber,
  IsOptional,
  IsArray,
  IsBoolean,
  Min,
} from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class CreateProductDto {
  @ApiProperty({ example: 'Harissa Sicam', description: 'Product name' })
  @IsNotEmpty()
  @IsString()
  name!: string;

  @ApiPropertyOptional({
    example: 'Authentic Tunisian Harissa',
    description: 'Product description',
  })
  @IsOptional()
  @IsString()
  description?: string;

  @ApiProperty({ example: 2.5, description: 'Product price in TND' })
  @IsNotEmpty()
  @IsNumber()
  @Min(0)
  price!: number;

  @ApiProperty({ example: 100, description: 'Stock quantity' })
  @IsNotEmpty()
  @IsNumber()
  @Min(0)
  stock!: number;

  @ApiProperty({ example: '507f1f77bcf86cd799439011', description: 'Merchant ID' })
  @IsNotEmpty()
  @IsString()
  merchantId!: string;

  @ApiPropertyOptional({ example: ['507f1f77bcf86cd799439011'], description: 'Category IDs' })
  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  categoryIds?: string[];

  @ApiPropertyOptional({ example: ['Spicy', 'Bio'], description: 'Product tags' })
  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  tags?: string[];

  @ApiPropertyOptional({
    example: ['https://example.com/image.jpg'],
    description: 'Product images',
  })
  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  images?: string[];

  @ApiPropertyOptional({
    example: ['507f1f77bcf86cd799439011'],
    description: 'Related product IDs',
  })
  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  relatedProductIds?: string[];

  @ApiPropertyOptional({ example: ['Tunis', 'Sfax'], description: 'Available regions' })
  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  regions?: string[];

  @ApiPropertyOptional({ example: true, description: 'Is product active' })
  @IsOptional()
  @IsBoolean()
  isActive?: boolean;
}
