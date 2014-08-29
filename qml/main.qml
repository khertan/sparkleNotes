import QtQuick 2.2
import QtQuick.Window 2.1
import "KComponents"
import "KComponents/theme.js" as Theme
import 'KComponents/icons/icons.js' as Icons

Window {
    id: root
    property bool loadPageInProgress: false
    property real scaleFactor: (width < height) ? (width / 480) : (height / 480)
    property int dialogsVisible: 0
    default property alias children: listPage.children

    visible: true
    width: 768
    height: 1280

    FontLoader {
        id: fontLoader
        source: Qt.resolvedUrl("KComponents/icons/open-iconic.ttf")
    }

    function topOfStackChanged(offset) {
        if (offset === undefined) {
            offset = 0;
        }
        var page = children[children.length+offset-1];
    }

    function update(page, x) {
        var index = -1;
        for (var i=0; i<children.length; i++) {
            if (children[i] === page) {
                index = i;                
                break;
            }
        }

        if (page.isDialog) {
            children[index-1].opacity = 1;
        } else if (children != undefined) {

        } else {
            children[index-1].opacity = x / width;
        }

        //children[index-1].pushPhase = x / width;
    }

    //showConfirmation("Are you sure ?", "Yes", "No", "Click on yes will close that dialog, and confirm that you are sure.")
    function showConfirmation(title, affirmative, negative, description, icon, callback) {
        loadPage('KComponents/Confirmation.qml', {
                     title: title,
                     affirmativeAction: affirmative,
                     negativeAction: negative,
                     description: description,
                     icon: icon,
                     callback: callback,
                 });
    }

    function editNote(path) {
        loadPage('EditPage.qml', { path: path, } );
    }

    function showSelection(items, title, selectedIndex) {
        Qt.inputMethod.hide();
        loadPage('KComponents/SelectionDialog.qml', {
                     title: title,
                     callback: function (index, item) {
                         items[index].callback();
                     },
                     items: function() {
                         var result = [];
                         for (var i in items) {
                             result.push(items[i].label);
                         }
                         return result;
                     }(),
                     selectedIndex: selectedIndex,
                 });
    }


    function loadPage(filename, properties) {
        if (root.loadPageInProgress) {
            console.log('ignoring loadPage request while load in progress');
            return;
        }

        var component = Qt.createComponent(filename);
        if (component.status != Component.Ready) {
            console.log('Error loading ' + filename + ':' +
                        component.errorString());
        }

        if (properties === undefined) {
            properties = {};
        }

        root.loadPageInProgress = true;
        component.createObject(root, properties);
    }

    function milisecondsToString(miliseconds) {
        try {
            //get different date time initials.
            var myDate = new Date();
            var difference_ms = myDate.getTime() - miliseconds * 1000;
            //take out milliseconds
            difference_ms = difference_ms / 1000;
            var seconds = Math.floor(difference_ms % 60);
            difference_ms = difference_ms / 60;
            var minutes = Math.floor(difference_ms % 60);
            difference_ms = difference_ms / 60;
            var hours = Math.floor(difference_ms % 24);
            difference_ms = difference_ms / 24;
            var days = Math.floor(difference_ms % 7);
            difference_ms = difference_ms / 7;
            var weeks = Math.floor(difference_ms);

            //remove weeks if it exceeds the month limit ie. 4weeks+2days.
            var months = 0;
            if ((weeks == 4 && days >= 2) || (weeks > 4)) {
                difference_ms = difference_ms * 7;
                days = Math.floor(difference_ms % 30);
                difference_ms = difference_ms / 30;
                months = Math.floor(difference_ms);
                weeks = 0;
            }
            //check and return the largest value of date time initialized.
            if (months > 0) {
                return months + "M ago";
            } else if (weeks != 0) {
                return weeks + "W ago";
            } else if (days != 0) {
                return days + "d ago";
            } else if (hours != 0) {
                return hours + "h ago";
            } else if (minutes != 0) {
                return minutes + "m ago";
            } else if (seconds != 0) {
                return seconds + "s ago";
            }
        } catch (e) {
            return 'Now';
            alert(e);
        }
        return 'Now';
    }


    Page {
        id: listPage
        anchors.fill: parent
        width: parent.width


        PageHeader {
            id: header
            title: 'SparkleNotes'
            bgColor: Theme.colors.fresh
            color: '#fff'
            anchors.left: parent.left
            anchors.right: parent.right

            MouseArea {
                anchors {
                    top: parent.top
                    left: parent.left
                    right: parent.right
                    rightMargin: 20 * root.scaleFactor
                    bottom: parent.bottom
                }

                onClicked: {
                    Qt.inputMethod.hide();
                }
            }

        }

        ScrollListView {
            id: notesList

            anchors {
                top: header.bottom
                bottom: toolbar.top
                right: parent.right
                left: parent.left
            }


            section.property: 'category'
            section.delegate: SectionHeader { text: section }
            Placeholder {
                text: 'No notes'
                visible: notesList.count === 0
            }
            model: notesModel
            delegate: NoteItem {
                onClicked: {
                    editNote(path);
                }
                onPressAndHold: {
                    root.showSelection([
                                           {
                                               label: 'Delete',
                                               callback: function () {
                                                   console.log('Delete :'+path)
                                               }
                                           } ,
                                           {
                                               label: 'Category',
                                               callback: function () {
                                                   console.log('Delete :'+path)
                                               }
                                           },
                                       ], title);
                }
            }
        }


        Toolbar {
            id:toolbar

            ToolbarButton {
                id:catTool
                icon: Icons.list
                //text: 'Plus'
            }

            ToolbarButton {
                icon: Icons.plus
                anchors.left: catTool.right
                //text: 'Plus'
                onClicked: {
                    notesModel.create();
                }
            }

            ToolbarButton {
                icon: Icons.menu
                anchors.right: parent.right
                onClicked: {
                    root.showSelection([
                                           {
                                               label: 'About',
                                               callback: function () {
                                                   console.log('show about');
                                                   loadPage('KComponents/AboutPage.qml', { } )
                                               }
                                           },
                                           {
                                               label: 'Settings',
                                               callback: function () {
                                                   loadPage('SettingsPage.qml', { } );
                                               }
                                           },

                                       ])
                }
            }


        }
    }
}
