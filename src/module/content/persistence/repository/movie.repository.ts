import { Injectable } from '@nestjs/common';
import { DefaultTypeOrmRepository } from '@sharedModules/persistence/typeorm/repository/default-typeorm.repository';
import { EntityManager } from 'typeorm';
import { Movie } from '@contentModule/persistence/entity/movie.entity';

@Injectable()
export class MovieRepository extends DefaultTypeOrmRepository<Movie> {
  constructor(readonly entityManager: EntityManager) {
    super(Movie, entityManager);
  }
}
