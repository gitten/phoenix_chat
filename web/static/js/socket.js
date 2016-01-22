// NOTE: The contents of this file will only be executed if
// you uncomment its entry in "web/static/js/app.js".

// To use Phoenix channels, the first step is to import Socket
// and connect at the socket path in "lib/my_app/endpoint.ex":
import {Socket} from "phoenix"

let socket = new Socket("/socket", {params: {token: window.userToken}})

// When you connect, you'll often need to authenticate the client.
// For example, imagine you have an authentication plug, `MyAuth`,
// which authenticates the session and assigns a `:current_user`.
// If the current user exists you can assign the user's token in
// the connection for use in the layout.
//
// In your "web/router.ex":
//
//     pipeline :browser do
//       ...
//       plug MyAuth
//       plug :put_user_token
//     end
//
//     defp put_user_token(conn, _) do
//       if current_user = conn.assigns[:current_user] do
//         token = Phoenix.Token.sign(conn, "user socket", current_user.id)
//         assign(conn, :user_token, token)
//       else
//         conn
//       end
//     end
//
// Now you need to pass this token to JavaScript. You can do so
// inside a script tag in "web/templates/layout/app.html.eex":
//
//     <script>window.userToken = "<%= assigns[:user_token] %>";</script>
//
// You will need to verify the user token in the "connect/2" function
// in "web/channels/user_socket.ex":
//
//     def connect(%{"token" => token}, socket) do
//       # max_age: 1209600 is equivalent to two weeks in seconds
//       case Phoenix.Token.verify(socket, "user socket", token, max_age: 1209600) do
//         {:ok, user_id} ->
//           {:ok, assign(socket, :user, user_id)}
//         {:error, reason} ->
//           :error
//       end
//     end
//
// Finally, pass the token on connect as below. Or remove it
// from connect if you don't care about authentication.

socket.connect()

let channel = socket.channel("rooms:lobby", {})
channel.join()
  .receive("ok", resp => {
    updateUserList(resp.user_list);
    userId = resp.user_id;
  })
  .receive("error", resp => { console.log("Unable to join", resp) })

let chatInput         = $("#chat-input")
let messagesContainer = $("#messages")
var userId;

chatInput.on("keypress", event => {
  if(event.keyCode === 13){
    channel.push("new_msg", {body: chatInput.val()})
    chatInput.val("")
  }
})

channel.on("new_msg", payload => {
  //messagesContainer.append(`<br/>[${Date()}] ${payload.body}`)
  //console.log(payload);
  //console.log(chatRowOther(payload));
  var self = payload.user_id == userId;
  //console.log(self);
  if (self) {
    messagesContainer.append(chatRowSelf(payload))
  } else {
    messagesContainer.append(chatRowOther(payload))
  }
})

channel.on("seek", payload => {
  player.seekTo(payload.body, true);
  console.log("seek" + payload.body);
  messagesContainer.append(`<br/>[[Seek video to: ${payload.body}]][${Date()}]`)
})

channel.on("speed", payload => {
  player.setPlaybackRate(payload.body)
  console.log("speed" + payload.body);
  messagesContainer.append(`<br/>[[New video speed: ${payload.body}]][${Date()}]`)
})

channel.on("pause", payload => {
  player.pauseVideo();
  console.log("pause" + payload.body);
  messagesContainer.append(`<br/>[[VIDEO PAUSED]][${Date()}]`)
})

channel.on("play", payload => {
  player.playVideo();
  console.log("play" + payload.body);
  messagesContainer.append(`<br/>[[PLAYING VIDEO]][${Date()}]`)
})

channel.on("heartbeat", payload => {
  updateUserList(payload.user_list)
  channel.push("heartbeat", {time: payload.time})
})

$(window).on('unload', function(){
  channel.push("close")
});

function updateUserList(userList) {
  $("#sidebarMenu .userRow").detach();
  var sidemenu = $("#sidebarMenu");
  var presentCount = 0, missingCount = 0;
  for (let user of userList) {
    if (user.presence === "present") {
      presentCount++;
      sidemenu.prepend(userListRow(user));
    } else {
      missingCount++;
    }
  }
  $("#totalUserCount").html(presentCount);
}

function userListRow(user) {
  var colorClass = getColorClassForGender(user.gender);
  return `<li class="active userRow"><a class="${colorClass}" href="#"><i class="fa fa-link"></i> <span>${user.name}</span></a></li>`;
}

function chatRowSelf(user) {
  var colorClass = getColorClassForGender(user.gender);
  return `<!-- Message to the right -->
      <div class="direct-chat-msg right">
        <div class="direct-chat-info clearfix">
          <span class="direct-chat-name pull-right">${user.name}</span>
          <span class="direct-chat-timestamp pull-left">${user.date}</span>
        </div><!-- /.direct-chat-info -->
        <img class="direct-chat-img" src="../dist/img/user3-128x128.jpg" alt="message user image"><!-- /.direct-chat-img -->
        <div class="direct-chat-text ${colorClass}">
          ${user.body}
        </div><!-- /.direct-chat-text -->
      </div><!-- /.direct-chat-msg -->
    </div><!-- /.direct-chat-messages-->`;
}

function chatRowOther(user) {
  var colorClass = getColorClassForGender(user.gender);
  return `<!-- Message. Default to the left -->
      <div class="direct-chat-msg">
        <div class="direct-chat-info clearfix">
          <span class="direct-chat-name pull-left">${user.name}</span>
          <span class="direct-chat-timestamp pull-right">${user.date}</span>
        </div><!-- /.direct-chat-info -->
        <img class="direct-chat-img" src="../dist/img/user1-128x128.jpg" alt="message user image"><!-- /.direct-chat-img -->
        <div class="direct-chat-text ${colorClass}">
          ${user.body}
        </div><!-- /.direct-chat-text -->
      </div><!-- /.direct-chat-msg -->`;
}

function getColorClassForGender(gender) {
  switch (gender) {
    case "m":
      return "bg-light-blue";
    case "f":
      return "bg-maroon";
    default:
      return "bg-purple";
  }
}

export default socket


var myNameModal = $('#myModal').modal();
$('#myName').focus();


$("#applyMyModal").click(function(){
  var name = $("#myName").val().trim();
  var gender =$("#myGender").val().trim();
  if (name === "" || gender === "") {
    alert('You must enter a name and gender');
    return;
  }
  channel.push("user_info", {name: name, gender: gender});
  myNameModal.modal('hide');
});
