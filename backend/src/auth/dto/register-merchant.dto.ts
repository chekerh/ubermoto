import { ApiProperty } from '@nestjs/swagger';
import { IsEmail, IsNotEmpty, IsString, MinLength } from 'class-validator';

export class MerchantRegisterDto {
  @ApiProperty({ example: 'owner@merchant.tn' })
  @IsEmail()
  email!: string;

  @ApiProperty({ example: 'StrongPassword123!' })
  @IsString()
  @MinLength(6)
  password!: string;

  @ApiProperty({ example: 'Hichem Store' })
  @IsNotEmpty()
  @IsString()
  merchantName!: string;

  @ApiProperty({ example: 'TND' })
  @IsNotEmpty()
  @IsString()
  region!: string;

  @ApiProperty({ example: 'Hichem Ben Ali' })
  @IsNotEmpty()
  @IsString()
  ownerName!: string;
}

