import 'package:custo_doce/data/local/database/database_helper.dart';
import 'package:custo_doce/data/local/models/assistant_action_model.dart';
import 'package:custo_doce/data/local/models/assistant_conversation_model.dart';
import 'package:custo_doce/data/local/models/assistant_message_model.dart';
import 'package:sqflite/sqflite.dart';

abstract class LocalAssistantDataSource {
  Future<AssistantConversationModel?> getLatestConversation();
  Future<void> saveConversation(AssistantConversationModel conversation);
  Future<void> updateConversation(AssistantConversationModel conversation);
  Future<List<AssistantMessageModel>> getMessages(String conversationId);
  Future<void> saveMessage(AssistantMessageModel message);
  Future<void> saveAction(AssistantActionModel action);
  Future<void> clearConversation(String conversationId);
}

class LocalAssistantDataSourceImpl implements LocalAssistantDataSource {
  final DatabaseHelper _dbHelper;

  LocalAssistantDataSourceImpl(this._dbHelper);

  @override
  Future<AssistantConversationModel?> getLatestConversation() async {
    final db = await _dbHelper.database;
    final rows = await db.query(
      'assistant_conversations',
      orderBy: 'updated_at DESC',
      limit: 1,
    );
    if (rows.isEmpty) {
      return null;
    }
    return AssistantConversationModel.fromMap(rows.first);
  }

  @override
  Future<void> saveConversation(AssistantConversationModel conversation) async {
    final db = await _dbHelper.database;
    await db.insert(
      'assistant_conversations',
      conversation.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> updateConversation(
    AssistantConversationModel conversation,
  ) async {
    final db = await _dbHelper.database;
    await db.update(
      'assistant_conversations',
      conversation.toMap(),
      where: 'id = ?',
      whereArgs: [conversation.id],
    );
  }

  @override
  Future<List<AssistantMessageModel>> getMessages(String conversationId) async {
    final db = await _dbHelper.database;
    final rows = await db.query(
      'assistant_messages',
      where: 'conversation_id = ?',
      whereArgs: [conversationId],
      orderBy: 'created_at ASC',
    );
    return rows.map(AssistantMessageModel.fromMap).toList();
  }

  @override
  Future<void> saveMessage(AssistantMessageModel message) async {
    final db = await _dbHelper.database;
    await db.insert(
      'assistant_messages',
      message.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> saveAction(AssistantActionModel action) async {
    final db = await _dbHelper.database;
    await db.insert(
      'assistant_actions',
      action.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> clearConversation(String conversationId) async {
    final db = await _dbHelper.database;
    await db.transaction((txn) async {
      await txn.delete(
        'assistant_actions',
        where: 'conversation_id = ?',
        whereArgs: [conversationId],
      );
      await txn.delete(
        'assistant_messages',
        where: 'conversation_id = ?',
        whereArgs: [conversationId],
      );
      await txn.delete(
        'assistant_conversations',
        where: 'id = ?',
        whereArgs: [conversationId],
      );
    });
  }
}
