import {
  Controller,
  Get,
  Post,
  Patch,
  Delete,
  Body,
  Param,
  UseGuards,
  Request,
  HttpCode,
  HttpStatus,
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth } from '@nestjs/swagger';
import { AddressesService } from './addresses.service';
import { CreateAddressDto, UpdateAddressDto } from './dto/create-address.dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';

interface AuthenticatedRequest extends Request {
  user: {
    sub: string;
    email: string;
    role: string;
  };
}

@ApiTags('addresses')
@Controller('users/addresses')
@UseGuards(JwtAuthGuard)
@ApiBearerAuth()
export class AddressesController {
  constructor(private readonly addressesService: AddressesService) {}

  @Get()
  @ApiOperation({ summary: 'Get all user addresses' })
  @ApiResponse({
    status: 200,
    description: 'Addresses retrieved successfully',
  })
  async findAll(@Request() req: AuthenticatedRequest) {
    return this.addressesService.findAllByUserId(req.user.sub);
  }

  @Post()
  @ApiOperation({ summary: 'Create a new address' })
  @ApiResponse({
    status: 201,
    description: 'Address created successfully',
  })
  async create(
    @Request() req: AuthenticatedRequest,
    @Body() createAddressDto: CreateAddressDto,
  ) {
    return this.addressesService.create(req.user.sub, createAddressDto);
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get address by ID' })
  @ApiResponse({
    status: 200,
    description: 'Address retrieved successfully',
  })
  @ApiResponse({ status: 404, description: 'Address not found' })
  async findOne(@Param('id') id: string, @Request() req: AuthenticatedRequest) {
    return this.addressesService.findOne(id, req.user.sub);
  }

  @Patch(':id')
  @ApiOperation({ summary: 'Update address' })
  @ApiResponse({
    status: 200,
    description: 'Address updated successfully',
  })
  @ApiResponse({ status: 404, description: 'Address not found' })
  async update(
    @Param('id') id: string,
    @Request() req: AuthenticatedRequest,
    @Body() updateAddressDto: UpdateAddressDto,
  ) {
    return this.addressesService.update(id, req.user.sub, updateAddressDto);
  }

  @Patch(':id/set-default')
  @ApiOperation({ summary: 'Set address as default' })
  @ApiResponse({
    status: 200,
    description: 'Address set as default successfully',
  })
  @ApiResponse({ status: 404, description: 'Address not found' })
  async setDefault(@Param('id') id: string, @Request() req: AuthenticatedRequest) {
    return this.addressesService.setDefault(id, req.user.sub);
  }

  @Delete(':id')
  @HttpCode(HttpStatus.NO_CONTENT)
  @ApiOperation({ summary: 'Delete address' })
  @ApiResponse({
    status: 204,
    description: 'Address deleted successfully',
  })
  @ApiResponse({ status: 404, description: 'Address not found' })
  async remove(@Param('id') id: string, @Request() req: AuthenticatedRequest) {
    await this.addressesService.delete(id, req.user.sub);
  }
}
