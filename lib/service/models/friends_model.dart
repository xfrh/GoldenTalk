
class Friend {
  String id;
  String useruid;
  String frienduid;
  String roomId;
  String avatar;
  String name;
  String email;
  String message;
  int status;

  Friend(
      {
      this.useruid,
      this.frienduid,
      this.roomId,
      this.avatar,
      this.name,
      this.email,
      this.message,
      this.status,
      });
  Friend.fromMap(Map snapshot, String id)
      : id = id ?? '',
        useruid = snapshot['useruid'] ?? '',
        frienduid = snapshot['frienduid'] ?? '',
        roomId = snapshot['roomId'] ?? '',
        avatar = snapshot['avatar'],
        name = snapshot['name'],
        email = snapshot['email'],
        status = snapshot['status'],
        message = snapshot['message'];

  toJson() {
    return {
      "id": id,
      "useruid": useruid,
      "frienduid": frienduid,
      "roomId": roomId,
      "avatar": avatar,
      "name": name,
      "email": email,
      "status":status,
      "message": message,
    };
  }
}
