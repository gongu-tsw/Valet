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
import com.thesecretworld.chronicle.Gongju.Collection.Node;
import GongjuListItemRenderer;

import com.Utils.ID32;
import com.Utils.LDBFormat;
import com.Utils.Signal;

import flash.geom.Point;

import mx.utils.Delegate;

import gfx.controls.Button;
import gfx.controls.CheckBox;
import gfx.controls.ScrollingList;
import gfx.controls.TextArea;

class ImportExportWindow extends MovieClip {
	
	public var SignalPositionChanged:Signal;
	public var SignalClosedWindow:Signal;
	private var m_This:MovieClip;
	
	// UI
	private var m_Background:MovieClip
    private var m_CodeEntryBox:MovieClip;
	private var m_ImportButton:MovieClip;
	private var m_ExportAllButton:MovieClip;
	private var m_ExportSelectionButton:MovieClip;
	
	// internal
	private var m_ParentWindow:MovieClip;
	private var m_ClothingDeckManagerImpl:ClothingDeckManagerImpl;
	
	public function ImportExportWindow() {
		super();
		
		m_This = this;
		Chat.SignalShowFIFOMessage.Emit("DEBUG: ImportExportWindow Creation", 0);
		
		SignalClosedWindow = new Signal();
		SignalPositionChanged = new Signal();;
		m_Background.onRelease = Delegate.create(this, handleStopDrag);
		m_Background.onReleaseOutside = Delegate.create(this, handleStopDrag);
		m_Background.onPress = Delegate.create(this, handleStartDrag);
	}
	
	public function configUI()
    {
		m_ExportAllButton.addEventListener("click", this, "ExportAll");
		m_ExportAllButton.addEventListener("focusIn", this, "RemoveFocus");
		m_ExportSelectionButton.addEventListener("click", this, "ExportSelection");
		m_ExportSelectionButton.addEventListener("focusIn", this, "RemoveFocus");
		m_ImportButton.addEventListener("click", this, "Import");
		m_ImportButton.addEventListener("focusIn", this, "RemoveFocus");
		
        super.configUI();
	}
	
	public function setParentWindow(parentWindow:MovieClip) {
		m_ParentWindow = parentWindow;
	}
	
	public function setClothingDeckManagerImpl(cdmi:ClothingDeckManagerImpl) {
		m_ClothingDeckManagerImpl = cdmi;
	}
	
	// Window wide events
	public function onLoad() {
		configUI();
	}
	
	private function onEnterFrame()
    {
    }
    
    private function handleStartDrag() {
		this.startDrag();
	}
	
	private function handleStopDrag(buttonIdx:Number) {
		this.stopDrag();
		SignalPositionChanged.Emit(this._x, this._y);
	}
	
	//
	private function ExportAll(event:Object) {
		
	}
	
	private function ExportSelection(event:Object) {
		
	}
	
	private function Import(event:Object) {
		
	}
	
	//Misc
	private function RemoveFocus()
    {
        Selection.setFocus(null);
    }
}