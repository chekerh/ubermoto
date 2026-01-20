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

@ApiTags('motorcycles')
@Controller('motorcycles')
@UseGuards(JwtAuthGuard)
export class MotorcyclesController {
  constructor(private readonly motorcyclesService: MotorcyclesService) {}

  @Post()
  @HttpCode(HttpStatus.CREATED)
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
  update(@Param('id') id: string, @Body() updateMotorcycleDto: UpdateMotorcycleDto) {
    return this.motorcyclesService.update(id, updateMotorcycleDto);
  }

  @Delete(':id')
  @HttpCode(HttpStatus.NO_CONTENT)
  remove(@Param('id') id: string) {
    return this.motorcyclesService.remove(id);
  }
}
