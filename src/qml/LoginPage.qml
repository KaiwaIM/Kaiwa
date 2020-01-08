/*
 *  Kaidan - A user-friendly XMPP client for every device!
 *
 *  Copyright (C) 2016-2020 Kaidan developers and contributors
 *  (see the LICENSE file for a full list of copyright authors)
 *
 *  Kaidan is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  In addition, as a special exception, the author of Kaidan gives
 *  permission to link the code of its release with the OpenSSL
 *  project's "OpenSSL" library (or with modified versions of it that
 *  use the same license as the "OpenSSL" library), and distribute the
 *  linked executables. You must obey the GNU General Public License in
 *  all respects for all of the code used other than "OpenSSL". If you
 *  modify this file, you may extend this exception to your version of
 *  the file, but you are not obligated to do so.  If you do not wish to
 *  do so, delete this exception statement from your version.
 *
 *  Kaidan is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with Kaidan.  If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.7
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.3 as Controls
import org.kde.kirigami 2.8 as Kirigami

import im.kaidan.kaidan 1.0

import "elements"

Kirigami.Page {
	title: qsTr("Log in")

	contextualActions: [
		Kirigami.Action {
			text: qsTr("Log in using a QR-Code")
			icon.name: "view-barcode"
			onTriggered: pageStack.layers.push(qrCodeScannerPage)
		}
	]

	ColumnLayout {
		anchors.fill: parent

		Kirigami.Heading {
			text: qsTr("Log in to your XMPP account")
			wrapMode: Text.WordWrap
			Layout.fillWidth: true
			horizontalAlignment: Qt.AlignHCenter
		}

		ColumnLayout {
			width: parent.width
			Layout.fillWidth: true

			// For desktop or tablet devices
			Layout.alignment: Qt.AlignCenter
			Layout.maximumWidth: Kirigami.Units.gridUnit * 25


			// JID field
			Controls.Label {
				id: jidLabel
				text: qsTr("Your Jabber-ID:")
			}
			Controls.TextField {
				id: jidField
				text: kaidan.jid
				placeholderText: qsTr("user@example.org")
				Layout.fillWidth: true
				selectByMouse: true
				inputMethodHints: Qt.ImhEmailCharactersOnly
			}

			// Password field
			Controls.Label {
				text: qsTr("Your Password:")
			}
			Controls.TextField {
				id: passField
				text: kaidan.password
				echoMode: TextInput.Password
				selectByMouse: true
				Layout.fillWidth: true
			}

			// Connect button
			CenteredAdaptiveHighlightedButton {
				id: connectButton
				label.text: qsTr("Connect")

				state: kaidan.connectionState !== Enums.StateDisconnected ? "connecting" : ""
				states: [
					State {
						name: "connecting"
						PropertyChanges {
							target: connectButton
							label.text: "<i>" + qsTr("Connecting…") + "</i>"
							label.color: "black"
							label.textFormat: Text.StyledText
							enabled: false
						}
					}
				]

				onClicked: {
					// connect to given account data
					kaidan.jid = jidField.text
					kaidan.password = passField.text
					kaidan.mainConnect()
				}
			}

			// connect when return was pressed
			Keys.onPressed: {
				if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
					if (jidField.activeFocus)
						passField.forceActiveFocus()
					else
						connectButton.clicked()
				}
			}
		}

		// placeholder
		Item {
			Layout.preferredHeight: Kirigami.Units.gridUnit * 3
		}
	}

	function handleConnectionError() {
		var error = kaidan.disconnReason
		if (error === Enums.ConnAuthenticationFailed) {
			passiveNotification(qsTr("Invalid username or password."))
		} else if (error === Enums.ConnNotConnected) {
			passiveNotification(qsTr("Cannot connect to the server. Please check your internet connection."))
		} else if (error === Enums.ConnTlsNotAvailable) {
			passiveNotification(qsTr("The server doesn't support secure connections."))
		} else if (error === Enums.ConnTlsFailed) {
			passiveNotification(qsTr("Error while trying to connect securely."))
		} else if (error === Enums.ConnDnsError) {
			passiveNotification(qsTr("Could not resolve the server's address. Please check your JID again."))
		} else if (error === Enums.ConnConnectionRefused) {
			passiveNotification(qsTr("Could not connect to the server."))
		} else if (error === Enums.ConnNoSupportedAuth) {
			passiveNotification(qsTr("Authentification protocol not supported by the server."))
		} else {
			passiveNotification(qsTr("An unknown error occured; see log for details."))
		}
	}

	Component.onCompleted: {
		kaidan.disconnReasonChanged.connect(handleConnectionError)
	}

	Component.onDestruction: {
		kaidan.disconnReasonChanged.disconnect(handleConnectionError)
	}
}
