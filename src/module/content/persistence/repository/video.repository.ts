import { Injectable } from '@nestjs/common';
import { DefaultTypeOrmRepository } from '@sharedModules/persistence/typeorm/repository/default-typeorm.repository';
import { EntityManager } from 'typeorm';
import { Video } from '@contentModule/persistence/entity/video.entity';

@Injectable()
export class VideoRepository extends DefaultTypeOrmRepository<Video> {
  constructor(readonly entityManager: EntityManager) {
    super(Video, entityManager);
  }
}
