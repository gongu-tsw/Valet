import com.Components.Window;

import com.GameInterface.Chat;
import com.GameInterface.DistributedValue;
import com.GameInterface.Game.Character;
import com.GameInterface.Game.CharacterBase;
import com.GameInterface.InventoryItem;
import com.GameInterface.Log;
import com.GameInterface.ShopInterface;
import com.GameInterface.Tooltip.Tooltip;
import com.GameInterface.Tooltip.TooltipData;
import com.GameInterface.Tooltip.TooltipManager;

import com.thesecretworld.chronicle.Gongju.ClothingDeckManagerImpl;

import com.Utils.Archive;
import com.Utils.LDBFormat;
import com.Utils.ID32;

import flash.geom.Point;
import gfx.controls.Button;
import mx.utils.Delegate;

import ValetWindow;

var m_WindowPosition:Point;
var m_ButtonPosition:Point;
var m_InspectTarget:Boolean;
var m_ValetWindow:ValetWindow;
var m_Icon:MovieClip;
var m_ClothingDeckManagerImpl:ClothingDeckManagerImpl;
var m_Tooltip;

//
var m_ValetOutfitChangeMonitor:DistributedValue;

// for Integration in 'Topbar Information Overload' by Viper
var m_VTIOIsLoadedMonitor:DistributedValue;
var VTIOAddonInfo:String = "Valet|Gongju|0.4.2|Valet_OptionWindowOpen|_root.valet_valet.m_Icon"; 
var m_OptionWindowState:DistributedValue;

// to have current defensive target for outfit copy
var clientChar:Character;
var m_CurrentDefensiveTarget:ID32;

function SlotCheckVTIOIsLoaded() {
	if (DistributedValue.GetDValue("VTIO_IsLoaded")) {
		DistributedValue.SetDValue("VTIO_RegisterAddon", VTIOAddonInfo);
	}
}

function SlotOptionWindowState() {
	var isOpen:Boolean = DistributedValue.GetDValue("Valet_OptionWindowOpen");
	SetOpenMainWindow(isOpen);
}


function onLoad() {
	//next 4 lines for Topbar Information Overload
	m_VTIOIsLoadedMonitor = DistributedValue.Create("VTIO_IsLoaded");
	m_VTIOIsLoadedMonitor.SignalChanged.Connect(SlotCheckVTIOIsLoaded, this);
	m_OptionWindowState = DistributedValue.Create("Valet_OptionWindowOpen");
	m_OptionWindowState.SignalChanged.Connect(SlotOptionWindowState, this);
	DistributedValue.SetDValue("Valet_OptionWindowOpen", false);
	
	m_ValetOutfitChangeMonitor = DistributedValue.Create("Valet_SelectOutfit");
	m_ValetOutfitChangeMonitor.SignalChanged.Connect(ChangeOutfit, this);
	
	clientChar = Character.GetClientCharacter();
	if (clientChar != undefined) {
		clientChar.SignalDefensiveTargetChanged.Connect(SlotDefensiveTargetChanged, this);
	}
	
	InitIcon();
	
	SlotCheckVTIOIsLoaded();
}

function ChangeOutfit() {
	if (m_ClothingDeckManagerImpl) {
		m_ClothingDeckManagerImpl.equipClothingSet(DistributedValue.GetDValue("Valet_SelectOutfit"));
	}
}

function SlotDefensiveTargetChanged(targetID:ID32)
{
	if (IsValidTarget(targetID) || targetID == undefined)
	{
		m_CurrentDefensiveTarget = targetID;
		if (m_ClothingDeckManagerImpl != undefined) {
			m_ClothingDeckManagerImpl.setDefensiveTarget(m_CurrentDefensiveTarget);
			
		}
		
		if (m_ValetWindow != undefined && m_ValetWindow != null) {
			m_ValetWindow.setDefensiveTarget(m_CurrentDefensiveTarget);
		}
	}
}

function IsValidTarget(targetID:ID32)
{
	return targetID.GetType() == _global.Enums.TypeID.e_Type_GC_Character || targetID.GetType() == 0;
}

// Module (de)activation
function OnModuleActivated(config:Archive) {
	
	m_WindowPosition = config.FindEntry("WindowPosition");
	if (m_WindowPosition == undefined) {
		m_WindowPosition = new Point();
		m_WindowPosition.x = 500;
		m_WindowPosition.y = 500;
	}
	
	m_ButtonPosition = config.FindEntry("ButtonPosition");
	if (m_ButtonPosition == undefined) {
		m_ButtonPosition = new Point();
		m_ButtonPosition.x = 8;
		m_ButtonPosition.y = 150;
	}
	
	m_InspectTarget = config.FindEntry("InspectTarget");
	if (m_InspectTarget == undefined) {
		m_InspectTarget = true;
	}
	
	if (DistributedValue.GetDValue("VTIO_IsLoaded") != true) {
		m_Icon._x = m_ButtonPosition.x;
		m_Icon._y = m_ButtonPosition.y;
	}
	
	m_ClothingDeckManagerImpl = new ClothingDeckManagerImpl();
	var deckList:Array = config.FindEntryArray("AllDecks");
	if (deckList == undefined) {
		deckList = [];
	} else {
		for (var idx:Number = 0; idx < deckList.length; ++idx) {
			var deckArchive:Archive = deckList[idx];
			m_ClothingDeckManagerImpl.addSerializedDeck(deckArchive);
		}
	}
	m_ClothingDeckManagerImpl.setDefensiveTarget(m_CurrentDefensiveTarget);
}

function OnModuleDeactivated() {
	var archive:Archive = new Archive();
	archive.AddEntry("ButtonPosition", m_ButtonPosition);
	archive.AddEntry("WindowPosition", m_WindowPosition);
	archive.AddEntry("InspectTarget", m_InspectTarget);
	
	var allDeckArchives:Array = m_ClothingDeckManagerImpl.serializeAllDeck()

	m_ClothingDeckManagerImpl = undefined;
	
	for (var idx:Number = 0; idx < allDeckArchives.length; ++idx) {
		archive.AddEntry("AllDecks", allDeckArchives[idx]);
	}
	
	if (m_ValetWindow != undefined && m_ValetWindow != null) {
		m_ValetWindow.removeMovieClip();
	}
	
	return archive;
}

function InitIcon() {
	m_ButtonPosition = config.FindEntry("ButtonPosition");
	if (m_ButtonPosition == undefined) {
		m_ButtonPosition = new Point();
		m_ButtonPosition.x = 8;z
		m_ButtonPosition.y = 150;
	} else {
		m_OpenIcon._x = m_ButtonPosition.x;
		m_OpenIcon._y = m_ButtonPosition.y;
	}
	
	/****/
	m_Tooltip = undefined
	m_Icon = attachMovie("Icon", "m_Icon", getNextHighestDepth());
	m_Icon._width = 18;
	m_Icon._height = 18;
	m_Icon.onMousePress = function(buttonID) {
		if (m_Tooltip != undefined)	m_Tooltip.Close();
		if (buttonID == 1) {
			// Do left mouse button stuff.
			SetOpenMainWindow((m_ValetWindow == undefined || !m_ValetWindow._visible));
		} else if (buttonID == 2) {
			// TODO add condition to forbid movement with VTIO
			if (DistributedValue.GetDValue("VTIO_IsLoaded") != true) {
				m_ButtonPosition.x = m_Icon._x;
				m_ButtonPosition.y = m_Icon._y;
				startDrag(m_Icon,0);
			}
		}
	}
	
	m_Icon.onMouseRelease = function(eventObj:Object) {
		if (m_Tooltip != undefined) m_Tooltip.Close();
		if (DistributedValue.GetDValue("VTIO_IsLoaded") != true) {
			m_ButtonPosition.x = m_Icon._x;
			m_ButtonPosition.y = m_Icon._y;
		}
		stopDrag();
	}
	
	var openCloseText:String = "Open/Close Valet";
	var languageCode:String =  LDBFormat.GetCurrentLanguageCode();
	if (languageCode == "fr") {
		openCloseText = "Ouvrir/Fermer Valet";
	}
	if (languageCode == "de") {
		openCloseText = "Valet öffnen/schließen";
	}
	
	m_Icon.onRollOver = function() {
		if (m_Tooltip != undefined) m_Tooltip.Close();
        var tooltipData:TooltipData = new TooltipData();
		tooltipData.AddAttribute("", "<font face='_StandardFont' size='13' color='#FF8000'><b>Valet</b></font>");
        tooltipData.AddAttributeSplitter();
        tooltipData.AddAttribute("", "");
        tooltipData.AddAttribute("", "<font face='_StandardFont' size='12' color='#FFFFFF'>" + openCloseText + "</font>");
        tooltipData.m_Padding = 4;
        tooltipData.m_MaxWidth = 210;
		m_Tooltip = TooltipManager.GetInstance().ShowTooltip(undefined, TooltipInterface.e_OrientationVertical, 0, tooltipData);
	}
	m_Icon.onRollOut = function() {
		if (m_Tooltip != undefined)	m_Tooltip.Close();
	}
}


function onElgaButtonPress() {
	m_ButtonPosition.x = m_OpenIcon._x;
	m_ButtonPosition.y = m_OpenIcon._y;
	startDrag(m_OpenIcon,0);
}

// Events
function onValetWindowUnload() {
	m_ValetWindow = undefined;
}

function onElgaButtonRelease(eventObj:Object) {
	stopDrag();
}

function onElgaButtonClick(eventObj:Object) {
	stopDrag();
	if (m_ButtonPosition.x == m_OpenIcon._x && m_ButtonPosition.y == m_OpenIcon._y) {
		SetOpenMainWindow((m_ValetWindow == undefined || !m_ValetWindow._visible));
	}
	else {
		m_ButtonPosition.x = m_OpenIcon._x;
		m_ButtonPosition.y = m_OpenIcon._y;
	}
	ResetFocus();
}

function SetOpenMainWindow(open:Boolean) {
	if (open) {
		if (m_ValetWindow == undefined)  {
			m_ValetWindow = attachMovie("ValetWindow", "window", getNextHighestDepth(),{m_ClothingDeckManagerImpl:m_ClothingDeckManagerImpl});
			
			//m_ValetWindow.setClothingDeckManagerImpl(m_ClothingDeckManagerImpl);
			m_ValetWindow._x = m_WindowPosition.x;
			m_ValetWindow._y = m_WindowPosition.y;
			m_ValetWindow.SignalPositionChanged.Connect(onPositionChanged, this);
			m_ValetWindow.onUnload = Delegate.create(this, onValetWindowUnload);
		}
		else {
			m_ValetWindow._visible = true;
		}
		DistributedValue.SetDValue("Valet_OptionWindowOpen", true);
	}
	else {
		if (m_ValetWindow != undefined)  {
			m_ValetWindow.removeMovieClip();
		}
		DistributedValue.SetDValue("Valet_OptionWindowOpen", false);
	}
}

function onPositionChanged(incX:Number, incY:Number) {
	m_WindowPosition.x = incX;
	m_WindowPosition.y = incY;
}

// Misc Functions

function ResetFocus() {
	Selection.setFocus(null);
}