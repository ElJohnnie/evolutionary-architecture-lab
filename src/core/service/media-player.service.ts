import { Injectable } from '@nestjs/common';
import { VideoNotFoundException } from '@src/core/exception/video-not-found.exception';
import { PrismaService } from '@src/persistence/prisma/prisma.service';

@Injectable()
export class MediaPlayerService {
  constructor(private readonly prismaService: PrismaService) {}

  async prepareStreaming(videoId: string) {
    const video = await this.prismaService.video.findUnique({
      where: {
        id: videoId,
      },
    });
    if (!video) {
      throw new VideoNotFoundException(`video with id ${videoId} not found`);
    }
    return video?.url;
  }
}
