import { Controller, Post, Body, UseGuards, Request, HttpCode, HttpStatus } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth } from '@nestjs/swagger';
import { FirebaseService } from './firebase.service';
import { UpdateFcmTokenDto, SendPushDto } from './dto/firebase.dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { UsersService } from '../users/users.service';

@ApiTags('firebase')
@Controller('firebase')
@UseGuards(JwtAuthGuard)
@ApiBearerAuth()
export class FirebaseController {
  constructor(
    private readonly firebaseService: FirebaseService,
    private readonly usersService: UsersService,
  ) {}

  @Post('register-token')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Register/update FCM token for the authenticated user' })
  @ApiResponse({ status: 200, description: 'FCM token registered successfully.' })
  async registerFcmToken(@Request() req: any, @Body() updateFcmTokenDto: UpdateFcmTokenDto) {
    const userId = req.user.sub;
    await this.usersService.updateFcmToken(userId, updateFcmTokenDto.fcmToken);
    return { message: 'FCM token registered', fcmToken: updateFcmTokenDto.fcmToken };
  }

  @Post('send-push')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Send a test push notification to a token' })
  @ApiResponse({ status: 200, description: 'Push notification sent.' })
  async sendPush(@Body() sendPushDto: SendPushDto) {
    const payload: any = {
      token: sendPushDto.token,
      notification: {
        title: sendPushDto.title,
        body: sendPushDto.body,
      },
    };
    if (sendPushDto.data) {
      payload.data = JSON.parse(sendPushDto.data);
    }
    const result = await this.firebaseService.sendToDevice(sendPushDto.token, payload);
    return result;
  }
}
