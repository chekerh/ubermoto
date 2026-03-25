import { Module } from '@nestjs/common';
import { FirebaseService } from './firebase.service';
import { FirebaseController } from './firebase.controller';
import { ConfigModule } from '@nestjs/config';
import { UsersModule } from '../users/users.module';
import { AuthModule } from '../auth/auth.module';

@Module({
  imports: [ConfigModule, UsersModule, AuthModule],
  controllers: [FirebaseController],
  providers: [FirebaseService],
  exports: [FirebaseService],
})
export class FirebaseModule {}
