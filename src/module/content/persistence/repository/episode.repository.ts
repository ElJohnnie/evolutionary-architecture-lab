import { DefaultTypeOrmRepository } from '@sharedModules/persistence/typeorm/repository/default-typeorm.repository';
import { Episode } from '@contentModule/persistence/entity/episode.entity';
import { Injectable } from '@nestjs/common';
import { EntityManager } from 'typeorm';

@Injectable()
export class EpisodeRepository extends DefaultTypeOrmRepository<Episode> {
  constructor(readonly entityManager: EntityManager) {
    super(Episode, entityManager);
  }

  async findByLastEpisodeByTvShowAndSeason(
    tvShowId: string,
    season: number,
  ): Promise<Episode | null> {
    return this.find({
      where: {
        tvShowId,
        season,
      },
      order: {
        number: 'DESC',
      },
    });
  }
}
