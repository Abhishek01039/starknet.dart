// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'msg_to_l1.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_MsgToL1 _$$_MsgToL1FromJson(Map<String, dynamic> json) => _$_MsgToL1(
      toAddress: json['to_address'] == null
          ? null
          : StarknetFieldElement.fromJson(json['to_address'] as String),
      payload: (json['payload'] as List<dynamic>?)
          ?.map((e) => StarknetFieldElement.fromJson(e as String))
          .toList(),
    );

Map<String, dynamic> _$$_MsgToL1ToJson(_$_MsgToL1 instance) =>
    <String, dynamic>{
      'to_address': instance.toAddress?.toJson(),
      'payload': instance.payload?.map((e) => e.toJson()).toList(),
    };
