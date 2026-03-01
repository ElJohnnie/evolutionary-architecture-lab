import { Module } from '@nestjs/common';
import { PrismaService } from '@src/persistence/prisma/prisma.service';
import { ContentController } from '@src/http/rest/controller/content.controller';
import { ContentManagementService } from '@src/core/service/content-management.service';
import { MediaPlayerService } from '@src/core/service/media-player.service';
import { ContentRepository } from '@src/persistence/repository/content.repository';
import { VideoRepository } from '@src/persistence/repository/video.repository';
import { MediaPlayerController } from '@src/http/rest/controller/media-player.controller';
import { ConfigModule } from '@src/infra/module/config/config.module';

@Module({
  imports: [ConfigModule.forRoot()],
  controllers: [ContentController, MediaPlayerController],
  providers: [
    PrismaService,
    ContentManagementService,
    MediaPlayerService,
    ContentRepository,
    VideoRepository,
  ],
})
export class AppModule {}
