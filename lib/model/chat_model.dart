class ChatModel {
  final String name;
  final String lastMessage;
  final String time;
  final String id;
  final String chatId;
  final String peerId;
  final String avatarUrl;

  ChatModel(
      {this.name,
      this.lastMessage,
      this.time,
      this.avatarUrl,
      this.chatId,
      this.id,
      this.peerId});
}

List<ChatModel> dummy = [
  new ChatModel(
      name: "GDG Ankara",
      lastMessage: "this is going well",
      time: "2:00 AM",
      chatId: "0",
      id: "0",
      peerId: "1",
      avatarUrl:
          "https://secure.meetupstatic.com/photos/event/e/2/a/7/600_484438023.jpeg"),
  new ChatModel(
      name: "Akif",
      lastMessage: "good",
      time: "3:00 AM",
      id: "1",
      peerId: "0",
      chatId: "0",
      avatarUrl:
          "https://pbs.twimg.com/profile_images/972838345171767296/fgtKr1Nw_400x400.jpg"),
  new ChatModel(
      name: "Yüksel",
      lastMessage: "thanks",
      time: "6:00 AM",
      id: "0",
      peerId: "0",
      chatId: "6",
      avatarUrl:
      "http://0.gravatar.com/avatar/faa9b5d95144b737f1bbd44cbba32c55?s=512&d=mm&r=g"),
  new ChatModel(
      name: "Beyza",
      lastMessage: "thanks",
      time: "6:00 AM",
      id: "0",
      peerId: "0",
      chatId: "2",
      avatarUrl:
          "https://miro.medium.com/max/3150/1*_vqIEWFL1avthwRxfw5-iA@2x.jpeg"),
  new ChatModel(
      name: "Sezer",
      lastMessage: "Hehe",
      id: "0",
      peerId: "0",
      time: "2:03 PM",
      chatId: "3",
      avatarUrl: "https://www.cs.hacettepe.edu.tr/images/temsilci/1.jpg"),
  new ChatModel(
      name: "Sena",
      lastMessage: "dude",
      id: "0",
      peerId: "0",
      time: "3:20 AM",
      chatId: "4",
      avatarUrl:
          "https://pbs.twimg.com/profile_images/1170418246144712705/-poPYruv_400x400.jpg"),
  new ChatModel(
      name: "Güney",
      lastMessage: "Hey, you are doing god",
      time: "3:00 AM",
      id: "0",
      peerId: "0",
      chatId: "5",
      avatarUrl:
          "https://anlatsin.com/media/user/avatar/guney-kirik_1549528535.jpg"),

];
