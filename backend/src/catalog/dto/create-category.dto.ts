import { IsNotEmpty, IsString, IsOptional, IsBoolean } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class CreateCategoryDto {
  @ApiProperty({ example: 'Épices & Condiments', description: 'Category name' })
  @IsNotEmpty()
  @IsString()
  name!: string;

  @ApiProperty({ example: 'spices-condiments', description: 'Category slug (URL-friendly)' })
  @IsNotEmpty()
  @IsString()
  slug!: string;

  @ApiPropertyOptional({
    example: '507f1f77bcf86cd799439011',
    description: 'Parent category ID for nested categories',
  })
  @IsOptional()
  @IsString()
  parentId?: string;

  @ApiPropertyOptional({ example: true, description: 'Is category active' })
  @IsOptional()
  @IsBoolean()
  isActive?: boolean;
}
