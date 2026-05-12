// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_meta_isar_schema.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetSyncMetaIsarSchemaCollection on Isar {
  IsarCollection<SyncMetaIsarSchema> get syncMetaIsarSchemas =>
      this.collection();
}

const SyncMetaIsarSchemaSchema = CollectionSchema(
  name: r'SyncMetaIsarSchema',
  id: -7642270687391527600,
  properties: {
    r'lastSyncAt': PropertySchema(
      id: 0,
      name: r'lastSyncAt',
      type: IsarType.dateTime,
    )
  },
  estimateSize: _syncMetaIsarSchemaEstimateSize,
  serialize: _syncMetaIsarSchemaSerialize,
  deserialize: _syncMetaIsarSchemaDeserialize,
  deserializeProp: _syncMetaIsarSchemaDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _syncMetaIsarSchemaGetId,
  getLinks: _syncMetaIsarSchemaGetLinks,
  attach: _syncMetaIsarSchemaAttach,
  version: '3.1.0+1',
);

int _syncMetaIsarSchemaEstimateSize(
  SyncMetaIsarSchema object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  return bytesCount;
}

void _syncMetaIsarSchemaSerialize(
  SyncMetaIsarSchema object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.lastSyncAt);
}

SyncMetaIsarSchema _syncMetaIsarSchemaDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = SyncMetaIsarSchema();
  object.id = id;
  object.lastSyncAt = reader.readDateTimeOrNull(offsets[0]);
  return object;
}

P _syncMetaIsarSchemaDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTimeOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _syncMetaIsarSchemaGetId(SyncMetaIsarSchema object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _syncMetaIsarSchemaGetLinks(
    SyncMetaIsarSchema object) {
  return [];
}

void _syncMetaIsarSchemaAttach(
    IsarCollection<dynamic> col, Id id, SyncMetaIsarSchema object) {
  object.id = id;
}

extension SyncMetaIsarSchemaQueryWhereSort
    on QueryBuilder<SyncMetaIsarSchema, SyncMetaIsarSchema, QWhere> {
  QueryBuilder<SyncMetaIsarSchema, SyncMetaIsarSchema, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension SyncMetaIsarSchemaQueryWhere
    on QueryBuilder<SyncMetaIsarSchema, SyncMetaIsarSchema, QWhereClause> {
  QueryBuilder<SyncMetaIsarSchema, SyncMetaIsarSchema, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<SyncMetaIsarSchema, SyncMetaIsarSchema, QAfterWhereClause>
      idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<SyncMetaIsarSchema, SyncMetaIsarSchema, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<SyncMetaIsarSchema, SyncMetaIsarSchema, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<SyncMetaIsarSchema, SyncMetaIsarSchema, QAfterWhereClause>
      idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension SyncMetaIsarSchemaQueryFilter
    on QueryBuilder<SyncMetaIsarSchema, SyncMetaIsarSchema, QFilterCondition> {
  QueryBuilder<SyncMetaIsarSchema, SyncMetaIsarSchema, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<SyncMetaIsarSchema, SyncMetaIsarSchema, QAfterFilterCondition>
      idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<SyncMetaIsarSchema, SyncMetaIsarSchema, QAfterFilterCondition>
      idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<SyncMetaIsarSchema, SyncMetaIsarSchema, QAfterFilterCondition>
      idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SyncMetaIsarSchema, SyncMetaIsarSchema, QAfterFilterCondition>
      lastSyncAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastSyncAt',
      ));
    });
  }

  QueryBuilder<SyncMetaIsarSchema, SyncMetaIsarSchema, QAfterFilterCondition>
      lastSyncAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastSyncAt',
      ));
    });
  }

  QueryBuilder<SyncMetaIsarSchema, SyncMetaIsarSchema, QAfterFilterCondition>
      lastSyncAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastSyncAt',
        value: value,
      ));
    });
  }

  QueryBuilder<SyncMetaIsarSchema, SyncMetaIsarSchema, QAfterFilterCondition>
      lastSyncAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastSyncAt',
        value: value,
      ));
    });
  }

  QueryBuilder<SyncMetaIsarSchema, SyncMetaIsarSchema, QAfterFilterCondition>
      lastSyncAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastSyncAt',
        value: value,
      ));
    });
  }

  QueryBuilder<SyncMetaIsarSchema, SyncMetaIsarSchema, QAfterFilterCondition>
      lastSyncAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastSyncAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension SyncMetaIsarSchemaQueryObject
    on QueryBuilder<SyncMetaIsarSchema, SyncMetaIsarSchema, QFilterCondition> {}

extension SyncMetaIsarSchemaQueryLinks
    on QueryBuilder<SyncMetaIsarSchema, SyncMetaIsarSchema, QFilterCondition> {}

extension SyncMetaIsarSchemaQuerySortBy
    on QueryBuilder<SyncMetaIsarSchema, SyncMetaIsarSchema, QSortBy> {
  QueryBuilder<SyncMetaIsarSchema, SyncMetaIsarSchema, QAfterSortBy>
      sortByLastSyncAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSyncAt', Sort.asc);
    });
  }

  QueryBuilder<SyncMetaIsarSchema, SyncMetaIsarSchema, QAfterSortBy>
      sortByLastSyncAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSyncAt', Sort.desc);
    });
  }
}

extension SyncMetaIsarSchemaQuerySortThenBy
    on QueryBuilder<SyncMetaIsarSchema, SyncMetaIsarSchema, QSortThenBy> {
  QueryBuilder<SyncMetaIsarSchema, SyncMetaIsarSchema, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<SyncMetaIsarSchema, SyncMetaIsarSchema, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<SyncMetaIsarSchema, SyncMetaIsarSchema, QAfterSortBy>
      thenByLastSyncAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSyncAt', Sort.asc);
    });
  }

  QueryBuilder<SyncMetaIsarSchema, SyncMetaIsarSchema, QAfterSortBy>
      thenByLastSyncAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSyncAt', Sort.desc);
    });
  }
}

extension SyncMetaIsarSchemaQueryWhereDistinct
    on QueryBuilder<SyncMetaIsarSchema, SyncMetaIsarSchema, QDistinct> {
  QueryBuilder<SyncMetaIsarSchema, SyncMetaIsarSchema, QDistinct>
      distinctByLastSyncAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastSyncAt');
    });
  }
}

extension SyncMetaIsarSchemaQueryProperty
    on QueryBuilder<SyncMetaIsarSchema, SyncMetaIsarSchema, QQueryProperty> {
  QueryBuilder<SyncMetaIsarSchema, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<SyncMetaIsarSchema, DateTime?, QQueryOperations>
      lastSyncAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastSyncAt');
    });
  }
}
