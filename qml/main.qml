import QtQml 2.15
import QtQml.Models 2.15
import QtQml.StateMachine 1.15

import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Extras 1.4
//import QtQuick.Shapes 1.15
//import QtQuick.Particles 2.15
//import QtQuick.Timeline 1.0

import QtQuick.VirtualKeyboard 2.15
import QtQuick.VirtualKeyboard.Styles 2.15
import QtQuick.VirtualKeyboard.Settings 2.15

import QtQuick3D 1.15
import QtQuick3D.Materials 1.15
import QtQuick3D.Effects 1.15
import QtQuick3D.Helpers 1.15

import Qt.labs.animation 1.0
import Qt.labs.calendar 1.0
import Qt.labs.folderlistmodel 1.0
//import Qt.labs.lottieqt 1.0
import Qt.labs.platform 1.0
import Qt.labs.qmlmodels 1.0
import Qt.labs.settings 1.0
import Qt.labs.wavefrontmesh 1.0

import QtGraphicalEffects 1.15
import QtCharts 2.15
import QtDataVisualization 1.15
import QtWebSockets 1.15
import QtWebChannel 1.15

import Util 1.0
import Qaterial 1.0 as Qaterial

Qaterial.ApplicationWindow
{
  id: window
  title: "Qaterial Online"
  visible: true

  header: Qaterial.ToolBar
  {
    Row
    {
      anchors.right: parent.right
      Qaterial.ToolButton
      {
        id: formatHorizontalAlignCenter

        checked: true
        enabled: !fullScreen.checked && !formatHorizontalAlignLeft.checked && !formatHorizontalAlignRight.checked
        icon.source: Qaterial.Icons.formatHorizontalAlignCenter

        ToolTip.visible: hovered
        ToolTip.text: "Align Horizontal Center"

        onClicked: () => userParentItem.reload()
      }

      Qaterial.ToolButton
      {
        id: formatVerticalAlignCenter

        checked: true
        enabled: !fullScreen.checked && !formatVerticalAlignBottom.checked && !formatVerticalAlignTop.checked
        icon.source: Qaterial.Icons.formatVerticalAlignCenter

        ToolTip.visible: hovered
        ToolTip.text: "Align Vertical Center"

        onClicked: () => userParentItem.reload()
      }

      Qaterial.ToolSeparator {}

      Qaterial.ToolButton
      {
        id: formatHorizontalAlignLeft

        enabled: !fullScreen.checked && !formatHorizontalAlignCenter.checked
        icon.source: Qaterial.Icons.formatHorizontalAlignLeft

        ToolTip.visible: hovered
        ToolTip.text: "Align Left"

        onClicked: () => userParentItem.reload()
      }

      Qaterial.ToolButton
      {
        id: formatHorizontalAlignRight

        enabled: !fullScreen.checked && !formatHorizontalAlignCenter.checked
        icon.source: Qaterial.Icons.formatHorizontalAlignRight

        ToolTip.visible: hovered
        ToolTip.text: "Align Right"

        onClicked: () => userParentItem.reload()
      }

      Qaterial.ToolButton
      {
        id: formatVerticalAlignBottom

        enabled: !fullScreen.checked && !formatVerticalAlignCenter.checked
        icon.source: Qaterial.Icons.formatVerticalAlignBottom

        ToolTip.visible: hovered
        ToolTip.text: "Align Bottom"

        onClicked: () => userParentItem.reload()
      }

      Qaterial.ToolButton
      {
        id: formatVerticalAlignTop

        enabled: !fullScreen.checked && !formatVerticalAlignCenter.checked
        icon.source: Qaterial.Icons.formatVerticalAlignTop

        ToolTip.visible: hovered
        ToolTip.text: "Align Top"

        onClicked: () => userParentItem.reload()
      }

      Qaterial.ToolSeparator {}

      Qaterial.ToolButton
      {
        id: fullScreen

        enabled: !formatHorizontalAlignCenter.checked &&
                 !formatVerticalAlignCenter.checked &&
                 !formatHorizontalAlignLeft.checked &&
                 !formatHorizontalAlignRight.checked &&
                 !formatVerticalAlignBottom.checked &&
                 !formatVerticalAlignTop.checked
        icon.source: checked ? Qaterial.Icons.fullscreen : Qaterial.Icons.fullscreenExit

        ToolTip.visible: hovered
        ToolTip.text: checked ? "Fullscreen" : "Fullscreen Exit"

        onClicked: () => userParentItem.reload()
      }
    } // RowLayout
  } // ToolBar

  Connections
  {
      target: Util
      function onCodeChanged() { userParentItem.create(Util.code) }
  }

  Item
  {
    id: userParentItem
    anchors.fill: parent
    property var userItem: null

    function create(textComponent)
    {
      if(userItem)
          userItem.destroy()
      userItem = Qt.createQmlObject(textComponent, userParentItem, "userItem")

      if(userItem)
      {
        if(fullScreen.checked)
          userItem.anchors.fill = userParentItem
        if(formatHorizontalAlignCenter.checked)
          userItem.anchors.horizontalCenter = userParentItem.horizontalCenter
        if(formatVerticalAlignCenter.checked)
          userItem.anchors.verticalCenter = userParentItem.verticalCenter
        if(formatHorizontalAlignLeft.checked)
          userItem.anchors.left = userParentItem.left
        if(formatHorizontalAlignRight.checked)
          userItem.anchors.right = userParentItem.right
        if(formatVerticalAlignBottom.checked)
          userItem.anchors.bottom = userParentItem.bottom
        if(formatVerticalAlignTop.checked)
          userItem.anchors.top = userParentItem.top
      }
    }

    function reload()
    {
      userParentItem.create(Util.code)
    }

    Component.onCompleted: function()
    {
      Qt.styleHints.useHoverEffects = true
      userParentItem.create(Util.code)
    }
  }
}
