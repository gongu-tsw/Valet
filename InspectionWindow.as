import com.Components.Window;
import com.Components.SearchBox;

import com.GameInterface.Chat;
import com.GameInterface.DistributedValue;
import com.GameInterface.Game.Character;
import com.GameInterface.Game.CharacterBase;
import com.GameInterface.Inventory;
import com.GameInterface.InventoryItem;
import com.GameInterface.Log;
import com.GameInterface.ShopInterface;
import com.GameInterface.Tooltip.TooltipUtils;
import com.GameInterface.Tooltip.TooltipInterface;

import com.thesecretworld.chronicle.Gongju.ClothingDeckManagerImpl;
import com.thesecretworld.chronicle.Gongju.ClothingDeck;
import GongjuListItemRenderer;

import com.Utils.ID32;
import com.Utils.LDBFormat;
import com.Utils.Signal;

import flash.geom.Point;

import mx.utils.Delegate;

import gfx.controls.Button;
import gfx.controls.ScrollingList;

class InspectionWindow extends MovieClip {
	
	public var SignalPositionChanged:Signal;
	public var SignalClosedWindow:Signal;
	
	private var m_This:MovieClip;
	
	// UI instances
	private var m_Background:MovieClip
	private var m_TargetCheckBox:MovieClip;
	private var m_CopyButton:MovieClip;
	private var m_PreviewAllButton:MovieClip;
	private var m_ClothingDeckManagerImpl:ClothingDeckManagerImpl;
	private var m_CurrentDefensiveTarget:ID32;
	private var m_ParentWindow:MovieClip;
	
	private var inspectionText_Hats:Object;
	private var inspectionText_Headgear2:Object;
	private var inspectionText_Headgear1:Object;
	private var inspectionText_Neck:Object;
	private var inspectionText_Chest:Object;
	private var inspectionText_Back:Object;
	private var inspectionText_Hands:Object;
	private var inspectionText_Leg:Object;
	private var inspectionText_Feet:Object;
	private var inspectionText_Multislot:Object;
	
	public function setClothingDeckManagerImpl(cdmi:ClothingDeckManagerImpl) {
		m_ClothingDeckManagerImpl = cdmi;
	}
	
	public function setParentWindow(parentWindow:MovieClip) {
		m_ParentWindow = parentWindow;
	}
	
	public function InspectionWindow() {
		super();
		
		m_This = this;
		
		SignalClosedWindow = new Signal();
		SignalPositionChanged = new Signal();;
		m_Background.onRelease = Delegate.create(this, handleStopDrag);
		m_Background.onReleaseOutside = Delegate.create(this, handleStopDrag);
		m_Background.onPress = Delegate.create(this, handleStartDrag);
	}
	
	public function setDefensiveTarget(newDefensiveTarget:ID32) {
		m_CurrentDefensiveTarget = newDefensiveTarget;
		updateDisplay();
	}
	
	public function configUI()
    {
        super.configUI();
		m_CopyButton.addEventListener("click", this, "CopyClothingSet");
		m_CopyButton.addEventListener("focusIn", this, "RemoveFocus");
		m_TargetCheckBox.addEventListener("select", this, "updateDisplay");
		m_TargetCheckBox.addEventListener("focusIn", this, "RemoveFocus");
		m_PreviewAllButton.addEventListener("click", this, "PreviewAllFromTarget");
		m_PreviewAllButton.addEventListener("focusIn", this, "RemoveFocus");
		updateDisplay();
	}
	
	// Window wide events
	public function onLoad() {
		InitStaticData();
		configUI();
	}
	
	private function PreviewAllFromTarget(){
		m_ClothingDeckManagerImpl.PreviewAllFromTarget();
    }
	
	private function CopyClothingSet(event:Object) {
		m_ParentWindow.CopyClothingSet(event);
	}
	
	private function updateTextLineInInspectionPanel(clothName:String, lineLabel:Object) {
		var clothStatus:Number = m_ClothingDeckManagerImpl.getClothStatus(clothName);
		if (clothName != undefined) {
			lineLabel.htmlText = clothName;
			//probably a bad way to set the color
			if (clothStatus == 2) {
				lineLabel.textColor = 65280; // neon green
			} else if (clothStatus == 1) {
				lineLabel.textColor = 16777215; // white
			} else {
				lineLabel.textColor = 16711680; // red
			}
		} else {
			lineLabel.htmlText = "";
		}
	}
	
	public function updateDisplay() {
		Selection.setFocus(null);
		var clothingDeck:ClothingDeck = null;
		
		if (m_TargetCheckBox.selected) {
			var targetInventory:Inventory = 
				new Inventory(new com.Utils.ID32(_global.Enums.InvType.e_Type_GC_WearInventory, m_CurrentDefensiveTarget.GetInstance()));
			
			clothingDeck = m_ClothingDeckManagerImpl.createClothingDeckFromTarget(targetInventory, null, "");
		} else {
			clothingDeck = m_ParentWindow.getSelectedClothingDeck();
		}
		
		if (clothingDeck != undefined) {
			updateTextLineInInspectionPanel(clothingDeck.getHats(), this.inspectionText_Hats);
			updateTextLineInInspectionPanel(clothingDeck.getHeadgear2(), this.inspectionText_Headgear2);
			updateTextLineInInspectionPanel(clothingDeck.getHeadgear1(), this.inspectionText_Headgear1);
			updateTextLineInInspectionPanel(clothingDeck.getNeck(),this.inspectionText_Neck);
			updateTextLineInInspectionPanel(clothingDeck.getChest(), this.inspectionText_Chest);
			updateTextLineInInspectionPanel(clothingDeck.getBack(), this.inspectionText_Back);
			updateTextLineInInspectionPanel(clothingDeck.getHands(), this.inspectionText_Hands);
			updateTextLineInInspectionPanel(clothingDeck.getLeg(), this.inspectionText_Leg);
			updateTextLineInInspectionPanel(clothingDeck.getFeet(), this.inspectionText_Feet);
			updateTextLineInInspectionPanel(clothingDeck.getMultislot(), this.inspectionText_Multislot);
		}
	}
	
	public function onEnterFrame()
    {
		return;
    }
    
    private function handleStartDrag() {
		this.startDrag();
	}
	
	private function handleStopDrag(buttonIdx:Number) {
		this.stopDrag();
		SignalPositionChanged.Emit(this._x, this._y);
	}
	
	// used to set translations
	// not character dependent
	// will need update for new translations
	private function InitStaticData() {
		
		var languageCode:String =  LDBFormat.GetCurrentLanguageCode();
		
		if (languageCode == "de") {
			
		}
		
		if (languageCode == "fr") {
			
		}

		if (languageCode == "en") {
			
		}
	}
	
	//Misc
	private function RemoveFocus()
    {
        Selection.setFocus(null);
    }
}