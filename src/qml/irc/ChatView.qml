/*
 * Copyright © 2015-2016 Antti Lamminsalo
 *
 * This file is part of Orion.
 *
 * Orion is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * You should have received a copy of the GNU General Public License
 * along with Orion.  If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.0
import "../styles.js" as Styles

Item {
    id: root

    //Visibity status:
    //0 - hidden
    //1 - solid visible
    //2 - opaque
    property int status: 0
    onStatusChanged: {
        if (status > 2)
            status = 0
    }

    visible: status > 0

    property real _opacity: root.status > 1 ? 0.6 : 1.0

    Rectangle {
        anchors.fill: parent
        color: Styles.sidebarBg
        opacity: root._opacity
    }

    onVisibleChanged: {
        if (visible)
            _input.forceActiveFocus()
    }

    function joinChannel(channel) {
        if ("#" + channel != chat.channel) {
            chatModel.clear()
            chat.joinChannel(channel)
        }
    }

    function leaveChannel() {
        chatModel.clear()
        chat.leaveChannel()
    }

    function sendMessage() {
        chat.sendChatMessage(_input.text)
        _input.text = ""
        list.positionViewAtEnd()
    }

    Connections {
        target: g_rootWindow

        onHeightChanged: {
            list.positionViewAtEnd()
        }
    }

    ListView {
        id: list

        property bool lock: true
        property int scrollbuf: 0
        property int previousY: 0

        model: ListModel {
            id: chatModel

            onCountChanged: {
                if (list.lock)
                    list.positionViewAtEnd()

                //Limit msg count in list
                if (chatModel.count > 300) {
                    chatModel.remove(0, 1)
                }
            }
        }

        clip: true
        highlightFollowsCurrentItem: false
        spacing: dp(10)
        boundsBehavior: Flickable.StopAtBounds

        delegate: ChatMessage {
            user: model.user
            msg: model.message
            isAction: model.isAction
            emoteDirPath: chat.emoteDirPath

            anchors {
                left: parent.left
                right: parent.right
            }
        }

        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            bottom: spacer.top
        }

        onContentYChanged: {
            if (atYEnd)
                lock = true;
            else if (scrollbuf < 0)
                lock = false
            else if (previousY > contentY)
                scrollbuf--

            previousY = contentY
        }
    }

    Rectangle {
        id: spacer
        anchors {
            left: parent.left
            right: parent.right
            bottom: inputArea.top
        }
        height: inputArea.visible ? dp(2) : 0
        color: Styles.border

        opacity: root._opacity
    }

    Item {
        id: inputArea

        height: !chat.isAnonymous ? dp(45) : 0
        anchors {
            bottom: parent.bottom
            left: parent.left
            right: parent.right
        }

        visible: !chat.isAnonymous

        Rectangle {
            anchors.fill: parent
            color: Styles.bg
            opacity: root._opacity
        }

        MouseArea {
            cursorShape: Qt.IBeamCursor
            anchors {
                fill: parent
            }

            TextInput{
                id: _input
                anchors {
                    fill: parent
                    margins: dp(5)
                }
                color: "#ffffff"
                clip:true
                selectionColor: Styles.purple
                focus: true
                selectByMouse: true
                font.pixelSize: Styles.titleFont.smaller
                verticalAlignment: Text.AlignVCenter

                Keys.onReturnPressed: sendMessage()
            }

        }

        MouseArea {
            id: _emoteButtonArea
            anchors {
                right: parent.right
            }
            onClicked: {
                console.log("current emote set ids")
                console.log(chat.lastEmoteSetIDs)
            }
            //hoverEnabled: true

            //onHoveredChanged: {
            //    _emoteButton.iconColor = containsMouse ? Styles.textColor : Styles.iconColor
            //}

            Text {
                id: _emoteButton
                anchors.centerIn: parent
                font.family: "FontAwesome"
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                text: FontAwesome.fromText("smile-o")
                font.bold: false
            }
        }

    }

    Chat {
        id: chat

        property variant colors:[]
        property string emoteDirPath
        property variant lastEmoteSetIDs

        function getRandomColor() {
            var letters = '0123456789ABCDEF';
            var color = '#';
            for (var i = 0; i < 6; i++ ) {
                color += letters[Math.floor(Math.random() * (letters.length - 1))];
            }
            return color;
        }

        onSetEmotePath: {
            emoteDirPath = value
        }

        onMessageReceived: {
            //console.log("ChatView chat override onMessageReceived; typeof message " + typeof(message) + " toString: " + message.toString())

            if (chatColor != "") {
                colors[user] = chatColor;
            }

            if (!colors[user]) {
                colors[user] = getRandomColor()
            }

            // ListElement doesn't support putting in an array value, ugh.
            var serializedMessage = JSON.stringify(message);
            //console.log("Sending: " + serializedMessage);
            chatModel.append({"user": user, "message": serializedMessage, "isAction": isAction})
            list.scrollbuf = 6
        }

        onEmoteSetIDsChanged: {
            lastEmoteSetIDs = emoteSetIDs
        }

        onClear: {
            chatModel.clear()
        }
    }
}
