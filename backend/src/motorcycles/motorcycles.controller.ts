import {
  Controller,
  Get,
  Post,
  Body,
  Patch,
  Param,
  Delete,
  UseGuards,
  HttpCode,
  HttpStatus,
} from '@nestjs/common';
import { ApiTags } from '@nestjs/swagger';
import { MotorcyclesService } from './motorcycles.service';
import { CreateMotorcycleDto } from './dto/create-motorcycle.dto';
import { UpdateMotorcycleDto } from './dto/update-motorcycle.dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../auth/guards/roles.guard';
import { Roles } from '../auth/decorators/roles.decorator';
import { UserRole } from '../users/schemas/user.schema';

@ApiTags('motorcycles')
@Controller('motorcycles')
@UseGuards(JwtAuthGuard, RolesGuard)
export class MotorcyclesController {
  constructor(private readonly motorcyclesService: MotorcyclesService) {}

  @Post()
  @HttpCode(HttpStatus.CREATED)
  @Roles(UserRole.ADMIN, UserRole.DRIVER)
  create(@Body() createMotorcycleDto: CreateMotorcycleDto) {
    return this.motorcyclesService.create(createMotorcycleDto);
  }

  @Get()
  findAll() {
    return this.motorcyclesService.findAll();
  }

  @Get(':id')
  findOne(@Param('id') id: string) {
    return this.motorcyclesService.findOne(id);
  }

  @Patch(':id')
  @Roles(UserRole.ADMIN, UserRole.DRIVER)
  update(@Param('id') id: string, @Body() updateMotorcycleDto: UpdateMotorcycleDto) {
    return this.motorcyclesService.update(id, updateMotorcycleDto);
  }

  @Delete(':id')
  @HttpCode(HttpStatus.NO_CONTENT)
  @Roles(UserRole.ADMIN)
  remove(@Param('id') id: string) {
    return this.motorcyclesService.remove(id);
  }
}
