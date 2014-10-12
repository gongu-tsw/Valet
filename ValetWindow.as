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

class ValetWindow extends MovieClip {
	
	private static var ACTION_CREATE:Number = 0;
	private static var ACTION_OVERWRITE:Number = 1;
	private static var ACTION_RENAME:Number = 2;
	private static var ACTION_DELETE:Number = 3;
	private static var ACTION_LOAD:Number = 4;
	private static var ACTION_COPY:Number = 5;
	
	public var SignalPositionChanged:Signal;
	public var SignalClosedWindow:Signal;
	
	private var m_This:MovieClip;
	
	// translations
	private var renameHeadline:String;
	private var overwriteHeadline:String;
	private var createHeadline:String;
	private var deleteHeadline:String;
	private var copyHeadline:String;
	
	private var renameText:String;
	private var overwriteText:String;
	private var createText:String;
	private var deleteText:String;
	private var copyText:String;
	
	// UI instances
	private var m_Background:MovieClip
	
	private var m_DeleteButton:Button;
	private var m_AddButton:Button;
	private var m_OverwriteButton:Button;
	private var m_RenameButton:Button;
	private var m_CloseButton:Button;
	private var m_EquipButton:Button;
	private var m_InspectionButton:Button;
	private var m_ImportExportButton:Button;
	
	private var m_MoveTopButton:Button;
	private var m_MoveUpButton:Button;
	private var m_MoveDownButton:Button;
	private var m_MoveBottomButton:Button;
	
	private var m_InspectionPanel:MovieClip;
	private var m_IsInspectionPanelOpen:Boolean;
	private var m_ConfirmPanel:MovieClip;
	private var m_IsConfimationPanelOpen:Boolean;
	private var m_ImportExportPanel:MovieClip;
	private var m_IsImportExportPanelOpen:Boolean;
	
	private var m_UserInput:Boolean;
	private var m_CheckInterval:Number;
    private var m_PositiveLabel:String;
	private var m_Validator:MovieClip;
	private var m_ValidatorText:TextField;
	private var m_FilterBox:SearchBox;
	
	public var m_ClothingDeckManagerImpl:ClothingDeckManagerImpl;
	
	private var m_ItemList:ScrollingList;
	private var m_Action:Number;
	private var m_CurrentDefensiveTarget:ID32;
	
	public function setClothingDeckManagerImpl(cdmi:ClothingDeckManagerImpl) {
		m_ClothingDeckManagerImpl = cdmi;
	}
	
	public function ValetWindow() {
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
		if (m_InspectionPanel != null) {
			m_InspectionPanel.setDefensiveTarget(newDefensiveTarget);
		}
	}
	
	public function configUI()
    {
        super.configUI();
		
		m_CloseButton.addEventListener("click", this, "CloseWindow");
		
		m_Background.addEventListener("focusIn", this, "RemoveListSelection");
		m_Background.addEventListener("focusOut", this, "RemoveListSelection");
		
		m_DeleteButton.addEventListener("click", this, "DeleteClothingSet");
		m_DeleteButton.addEventListener("focusIn", this, "RemoveFocus");
		m_DeleteButton.label = LDBFormat.LDBGetText("GenericGUI", "Delete");
		m_DeleteButton.disabled = true;
		
		m_AddButton.addEventListener("click", this, "AddClothingSet");
		m_AddButton.addEventListener("focusIn", this, "RemoveFocus");
		m_AddButton.label = LDBFormat.LDBGetText("GenericGUI", "Save");
		
		m_RenameButton.addEventListener("click", this, "RenameClothingSet");
		m_RenameButton.addEventListener("focusIn", this, "RemoveFocus");
		m_RenameButton.label = LDBFormat.LDBGetText("GenericGUI", "Save");
		m_RenameButton.disabled = true;
		
		m_EquipButton.addEventListener("click", this, "EquipClothingSet");
		m_EquipButton.addEventListener("focusIn", this, "RemoveFocus");
		m_EquipButton.disabled = true;
		
		m_OverwriteButton.addEventListener("click", this, "OverwriteClothingSet");
		m_OverwriteButton.addEventListener("focusIn", this, "RemoveFocus");
		m_OverwriteButton.label = LDBFormat.LDBGetText("CharStatSkillGUI", "OverwriteBuild");
		m_OverwriteButton.disabled = true;
		
		m_InspectionButton.addEventListener("click", this, "ShowHideInspectionWindow");
		m_InspectionButton.addEventListener("focusIn", this, "RemoveFocus");
		
		m_ImportExportButton.addEventListener("click", this, "ShowHideImportExportWindow");
		m_ImportExportButton.addEventListener("focusIn", this, "RemoveFocus");
		
		m_MoveTopButton.addEventListener("focusIn", this, "RemoveFocus");
		m_MoveUpButton.addEventListener("focusIn", this, "RemoveFocus");
		m_MoveDownButton.addEventListener("focusIn", this, "RemoveFocus");
		m_MoveBottomButton.addEventListener("focusIn", this, "RemoveFocus");
		
		m_MoveTopButton.addEventListener("click", this, "MoveTopClothingSet");
		m_MoveUpButton.addEventListener("click", this, "MoveUpClothingSet");
		m_MoveDownButton.addEventListener("click", this, "MoveDownClothingSet");
		m_MoveBottomButton.addEventListener("click", this, "MoveBottomClothingSet");
		
		m_MoveTopButton.disabled = true;
		m_MoveUpButton.disabled = true;
		m_MoveDownButton.disabled = true;
		m_MoveBottomButton.disabled = true;
		
		m_ItemList.addEventListener("focusIn", this, "RemoveFocus");
        m_ItemList.addEventListener("itemClick", this, "OnItemListSelected");
		m_ItemList.addEventListener("itemDoubleClick", this, "EquipClothingSet");
		
		m_FilterBox.SetSearchOnInput(true);
		//m_FilterBox.SetDefaultText(LDBFormat.LDBGetText("GenericGUI", "SearchText"));
		m_FilterBox.addEventListener("search", this, "FilterTextChanged");
		
		InitList();
	}
	
	public function RemoveListSelection(event:Object) {
		m_ItemList.selectedIndex = -1;
	}
	
	// Window wide events
	public function onLoad() {
		InitStaticData();
		configUI();
	}
	
	private function DisableMainWindowButton(disable:Boolean) {
		m_AddButton.disabled = disable;
		m_ItemList.disabled = disable;
		var searchText:String = m_FilterBox.GetSearchText().toLowerCase();
		var filterActive:Boolean = (searchText.length != 0);
		if (m_ItemList.selectedIndex != -1) {
			m_DeleteButton.disabled = disable;
			m_RenameButton.disabled = disable;
			m_OverwriteButton.disabled = disable;
			m_EquipButton.disabled = disable;
			
			if (m_ItemList.selectedIndex > 0) {
				m_MoveTopButton.disabled = disable || filterActive;
				m_MoveUpButton.disabled = disable || filterActive;
			} else {
				m_MoveTopButton.disabled = true;
				m_MoveUpButton.disabled = true;
			}
			if (m_ItemList.selectedIndex < m_ItemList.dataProvider.length - 1) {
				m_MoveDownButton.disabled = disable || filterActive;
				m_MoveBottomButton.disabled = disable|| filterActive;
			} else {
				m_MoveDownButton.disabled = true;
				m_MoveBottomButton.disabled = true;
			}
		}
		else {
			m_EquipButton.disabled = true;
			m_DeleteButton.disabled = true;
			m_RenameButton.disabled = true;
			m_OverwriteButton.disabled = true;
			m_MoveTopButton.disabled = true;
			m_MoveUpButton.disabled = true;
			m_MoveDownButton.disabled = true;
			m_MoveBottomButton.disabled = true;
		}
	}
	
	public function RenameClothingSet(event:Object) {
		if (m_ItemList.selectedIndex != -1) {
			m_Action = ACTION_RENAME;
			ShowConfirmationPanel();
			m_ConfirmPanel.m_Headline.htmlText = renameHeadline;//LDBFormat.LDBGetText("CharStatSkillGUI", "RenameBuild");
			m_ConfirmPanel.m_Body.htmlText = renameText;//LDBFormat.LDBGetText("CharStatSkillGUI", "RenameBuildBody");
			
			m_ConfirmPanel.m_InputTextField._visible = true;
			m_ConfirmPanel.m_InputTextField.m_NameText._text = m_ItemList.dataProvider[m_ItemList.selectedIndex].m_ItemName;
			
			m_PositiveLabel = LDBFormat.LDBGetText("GenericGUI", "RenameCAPS");
			
			m_UserInput = true;
			SetConfirmationWindow();
		}
	}
	
	public function DeleteClothingSet(event:Object) {
		if (m_ItemList.selectedIndex != -1) {
			m_Action = ACTION_DELETE;
			ShowConfirmationPanel();
			m_ConfirmPanel.m_Headline.htmlText = deleteHeadline; //LDBFormat.LDBGetText("CharStatSkillGUI", "DeleteBuild");
            m_ConfirmPanel.m_Body.autoSize = "center";
			m_ConfirmPanel.m_Body.htmlText = deleteText; //LDBFormat.LDBGetText("CharStatSkillGUI", "ConfirmDeleteBuild") + "<br><br>"
			+ m_ItemList.dataProvider[m_ItemList.selectedIndex].m_ItemName;
			
			m_ConfirmPanel.m_InputTextField._visible = false;
			
			m_PositiveLabel = LDBFormat.LDBGetText("GenericGUI", "Delete");
			
			SetConfirmationWindow();
		}
	}
	
	private function FilterTextChanged() {
		InitList();
		UpdateSortButtonEnabling();
	}
	
	private function ShowHideInspectionWindow() {
		if (m_IsInspectionPanelOpen === true) {
			m_IsInspectionPanelOpen = false;
			m_InspectionPanel.removeMovieClip();
			m_InspectionPanel = null; // good ?
		} else {
			m_IsInspectionPanelOpen = true;
			m_InspectionPanel = m_This.attachMovie("InspectionWindow", "myInspectionPanel", m_This.getNextHighestDepth());
			m_InspectionPanel._x = - m_InspectionPanel._width - 6;
			m_InspectionPanel.setClothingDeckManagerImpl(m_ClothingDeckManagerImpl);
			m_InspectionPanel.updateDisplay();
			m_InspectionPanel.setParentWindow(this);
		}
	}
	
	private function ShowHideImportExportWindow() {
		Chat.SignalShowFIFOMessage.Emit("DEBUG: Click ShowHideImportExportWindow", 0);
		if (m_IsImportExportPanelOpen === true) {
			m_IsImportExportPanelOpen = false;
			m_ImportExportPanel.removeMovieClip();
			m_ImportExportPanel = null; // good ?
		} else {
			m_IsImportExportPanelOpen = true;
			m_ImportExportPanel = m_This.attachMovie("ImportExportWindow", "myImportExportPanel", m_This.getNextHighestDepth());
			m_ImportExportPanel._x = - m_ImportExportPanel._width - 6;
			m_ImportExportPanel.setClothingDeckManagerImpl(m_ClothingDeckManagerImpl);
			m_ImportExportPanel.setParentWindow(this);
		}
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
	
	private function updateInspectionPanelDisplay() {
		if (m_InspectionPanel != null) {
			m_InspectionPanel.updateDisplay();
		}
	}
	
	private function ShowConfirmationPanel() {
		m_ConfirmPanel = m_This.attachMovie("EditNameWindow", "m_ConfirmPanel", m_This.getNextHighestDepth());
		m_IsConfimationPanelOpen = true;
		m_UserInput = false;
		DisableMainWindowButton(true);
	}
	
	public function SetConfirmationWindow() {
		m_ConfirmPanel._x = m_Background._width + 20;
		m_ConfirmPanel._y = 0;
        
		if (m_UserInput)
        {
            m_ValidatorText = m_ConfirmPanel.m_InputTextField.m_NameText.textField;

            if (m_Action != ACTION_OVERWRITE)
            {
                Key.addListener(this);
                
                m_Validator = m_ConfirmPanel.m_InputTextField.m_Validator;
                
                m_ValidatorText.onChanged = Delegate.create(this, VerifyBuildName);            
            }

            if (m_Action == ACTION_OVERWRITE)
            {
                m_ConfirmPanel.m_InputTextField.m_Validator.gotoAndStop("accept");
                m_ConfirmPanel.m_PositiveButton.disabled = false;
            }
        }

        m_CheckInterval = setInterval(CheckDialogComponentsInitialized, 20, this);
        
        m_ConfirmPanel.m_Background.onPress =  Delegate.create(this, ConfirmPanelMoveDragHandler);
        m_ConfirmPanel.m_Background.onRelease = m_ConfirmPanel.m_Background.onReleaseOutside = Delegate.create(this, ConfirmPanelMoveDragReleaseHandler);
	}
	
	public function getSelectedClothingDeck():ClothingDeck {
		var clothingDeck:ClothingDeck = null;
		if ( m_ItemList.selectedIndex != -1) {
			var currentSelection:String = m_ItemList.dataProvider[m_ItemList.selectedIndex].m_ItemName;
			clothingDeck = m_ClothingDeckManagerImpl.getDeck(currentSelection);
		}
		return clothingDeck;
	}
	
	private function VerifyBuildName():Void
	{
        /*
         * updates when a change to the Buildname is registered, shows the verification symbol and 
         * enabled / disables the save button
         * 
         */
        
		var text:String = m_ValidatorText.text;
		var isValid:Boolean = true;
		
		if (text == LDBFormat.LDBGetText("GenericGUI", "EnterName") || text.length < 1) {
			isValid = false;
		} else {
			for (var i:Number = 0; i < m_ItemList.dataProvider.length; i++) {
				if (m_ItemList.dataProvider[i].m_ItemName == text) {
					isValid = false;
					break;
				}
			}
		}
		if (text.indexOf("|") != -1) {
			isValid = false;
		}
		
		if (isValid) {
			m_Validator.gotoAndStop("accept");
            m_ConfirmPanel.m_PositiveButton.disabled = false;
		} else {
			m_Validator.gotoAndStop("alert");
            m_ConfirmPanel.m_PositiveButton.disabled = true;
		}
	}
	
	//Check Dialog Components Initialized
    private function CheckDialogComponentsInitialized(scope:Object):Void
    {
        if  (
            scope.m_ConfirmPanel.m_InputTextField.m_NameText.initialized  &&
            scope.m_ConfirmPanel.m_NegativeButton.initialized             &&
            scope.m_ConfirmPanel.m_PositiveButton.initialized
            )
        {
            clearInterval(scope.m_CheckInterval);
            
            if (scope.m_UserInput) {
                scope.m_ConfirmPanel.m_InputTextField.m_NameText.maxChars = 30;
                scope.m_ConfirmPanel.m_PositiveButton.disabled = true;
                Selection.setFocus(scope.m_ConfirmPanel.m_InputTextField.m_NameText.textField);
                Selection.setSelection(scope.m_ConfirmPanel.m_InputTextField.m_NameText.textField);
            }
            else {
                Selection.setFocus(null);
            }
            
            scope.m_ConfirmPanel.m_NegativeButton.label = LDBFormat.LDBGetText("GenericGUI", "Cancel");
            scope.m_ConfirmPanel.m_PositiveButton.label = scope.m_PositiveLabel; 
            scope.m_ConfirmPanel.m_NegativeButton.addEventListener("click", scope, "NegativeButtonClickHandler");
            scope.m_ConfirmPanel.m_PositiveButton.addEventListener("click", scope, "PositiveButtonClickHandler");
        }
    }
	
	//On Key Up
	private function onKeyUp():Void {
		if (Key.getCode() == Key.ENTER) {
			if (m_IsConfimationPanelOpen) {
				PositiveButtonClickHandler();
			}
			Key.removeListener(this);
		} else if (Key.getCode() == Key.ESCAPE) {
			if (m_IsConfimationPanelOpen) {
				NegativeButtonClickHandler();
			}
			Key.removeListener(this);
		}
	}
	
	private function PositiveButtonClickHandler(event:Object):Void {
        if (m_Action == ACTION_RENAME) {
            m_ClothingDeckManagerImpl.renameClothingSet(
				m_ItemList.dataProvider[m_ItemList.selectedIndex].m_ItemName,
				m_ValidatorText.text);
			InitList();
        } else if(m_Action == ACTION_CREATE)  {
			var newName:String = String(m_ValidatorText.text);
			m_ClothingDeckManagerImpl.addClothingSet(newName);
			InitList();
        } else if (m_Action == ACTION_OVERWRITE) {
			var newName:String = m_ItemList.dataProvider[m_ItemList.selectedIndex].m_ItemName;
			m_ClothingDeckManagerImpl.updateClothingSet(newName);
			InitList();
        } else if (m_Action == ACTION_DELETE) {
			var deleteName:String = m_ItemList.dataProvider[m_ItemList.selectedIndex].m_ItemName;
			m_ClothingDeckManagerImpl.deleteClothingSet(deleteName);
			InitList();
        } else if (m_Action == ACTION_COPY) {
			var newName:String = String(m_ValidatorText.text);
			m_ClothingDeckManagerImpl.copyClothingSet(newName);
			InitList();
		}
        
        NegativeButtonClickHandler();
    }
	
	private function NegativeButtonClickHandler(event:Object):Void
    {        
		CloseConfirmationPanel();
        DisableMainWindowButton(false);
	}
	
	public function AddClothingSet(event:Object) {
		m_Action = ACTION_CREATE;
		ShowConfirmationPanel();
		
		m_ConfirmPanel.m_Headline.htmlText = createHeadline; //LDBFormat.LDBGetText("CharStatSkillGUI", "SaveBuild");
		m_ConfirmPanel.m_Body.htmlText = createText; //LDBFormat.LDBGetText("CharStatSkillGUI", "SaveBuildBody");
			
		m_ConfirmPanel.m_InputTextField._visible = true;
        m_ConfirmPanel.m_InputTextField.m_NameText._visible = false;
		m_ConfirmPanel.m_InputTextField.m_NameText._text = LDBFormat.LDBGetText("GenericGUI", "EnterName");
			
		m_PositiveLabel = LDBFormat.LDBGetText("GenericGUI", "Save");

		m_UserInput = true;
		SetConfirmationWindow();
	}
	
	public function CopyClothingSet(event:Object) {
		Chat.SignalShowFIFOMessage.Emit("DEBUG: Call CopyClothingSet", 0);
		m_Action = ACTION_COPY;
		ShowConfirmationPanel();
		
		m_ConfirmPanel.m_Headline.htmlText = copyHeadline;
		m_ConfirmPanel.m_Body.htmlText = copyText;
			
		m_ConfirmPanel.m_InputTextField._visible = true;
        m_ConfirmPanel.m_InputTextField.m_NameText._visible = false;
		m_ConfirmPanel.m_InputTextField.m_NameText._text = LDBFormat.LDBGetText("GenericGUI", "EnterName");
			
		m_PositiveLabel = LDBFormat.LDBGetText("GenericGUI", "Save");

		m_UserInput = true;
		SetConfirmationWindow();
	}
		
	public function OverwriteClothingSet(event:Object) {
		if (m_ItemList.selectedIndex != -1) {
			// OVERWRITE
			m_Action = ACTION_OVERWRITE;
			ShowConfirmationPanel();
			
			// for Confirmation Panel
			m_ConfirmPanel.m_Headline.htmlText = overwriteHeadline; //LDBFormat.LDBGetText("CharStatSkillGUI", "OverwriteBuild");;
            m_ConfirmPanel.m_Body.autoSize = "center";
			m_ConfirmPanel.m_Body.htmlText = overwriteText; //LDBFormat.LDBGetText("CharStatSkillGUI", "OverwriteBuildBody") + "<br><br>"
			+ m_ItemList.dataProvider[m_ItemList.selectedIndex].m_ItemName;
			
			m_ConfirmPanel.m_InputTextField._visible = false;
			
			m_PositiveLabel = LDBFormat.LDBGetText("CharStatSkillGUI", "Overwrite");
			
			m_UserInput = true;
			SetConfirmationWindow();
		}
	}
	
	// Move item in list
		
	public function MoveTopClothingSet(event:Object) {
		if (m_ItemList.selectedIndex != -1) {
			var indexMemory:Number = m_ItemList.selectedIndex;
			var setName:String = m_ItemList.dataProvider[m_ItemList.selectedIndex].m_ItemName;
			m_ClothingDeckManagerImpl.moveClothingToTop(setName);
			InitList();
			m_ItemList.selectedIndex = 0;
			UpdateSortButtonEnabling();
		}
	}
	
	public function MoveUpClothingSet(event:Object) {
		if (m_ItemList.selectedIndex != -1) {
			var indexMemory:Number = m_ItemList.selectedIndex;
			var setName:String = m_ItemList.dataProvider[m_ItemList.selectedIndex].m_ItemName;
			m_ClothingDeckManagerImpl.moveClothingUp(setName);
			InitList();
			m_ItemList.selectedIndex = indexMemory - 1;
			UpdateSortButtonEnabling();
		}
	}
	
	public function MoveDownClothingSet(event:Object) {
		if (m_ItemList.selectedIndex != -1) {
			var indexMemory:Number = m_ItemList.selectedIndex;
			var setName:String = m_ItemList.dataProvider[m_ItemList.selectedIndex].m_ItemName;
			m_ClothingDeckManagerImpl.moveClothingDown(setName);
			InitList();
			m_ItemList.selectedIndex = indexMemory + 1;
			UpdateSortButtonEnabling();
		}
	}
	
	public function MoveBottomClothingSet(event:Object) {
		if (m_ItemList.selectedIndex != -1) {
			var indexMemory:Number = m_ItemList.dataProvider.length - 1;
			var setName:String = m_ItemList.dataProvider[m_ItemList.selectedIndex].m_ItemName;
			m_ClothingDeckManagerImpl.moveClothingToBottom(setName);
			InitList();
			m_ItemList.selectedIndex = indexMemory;
			UpdateSortButtonEnabling();
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
	
	// UI List events
	private function OnItemListSelected( event:Object )
    {
		m_RenameButton.disabled = false;
		m_DeleteButton.disabled = false;
		m_OverwriteButton.disabled = false;
		m_EquipButton.disabled = false
		
		updateInspectionPanelDisplay();
		
		UpdateSortButtonEnabling();
    }
	
	private function UpdateSortButtonEnabling() {
		var searchText:String = m_FilterBox.GetSearchText().toLowerCase();
		var filterIsActive:Boolean = (searchText.length != 0);
		if (m_ItemList.selectedIndex > 0 && !filterIsActive) {
			m_MoveTopButton.disabled = false;
			m_MoveUpButton.disabled = false;
		} else {
			m_MoveTopButton.disabled = true;
			m_MoveUpButton.disabled = true;
		}
		if (m_ItemList.selectedIndex < m_ItemList.dataProvider.length - 1 && !filterIsActive) {
			m_MoveDownButton.disabled = false;
			m_MoveBottomButton.disabled = false;
		} else {
			m_MoveDownButton.disabled = true;
			m_MoveBottomButton.disabled = true;
		}
	}
	
	public function EquipClothingSet(event:Object) {
		updateInspectionPanelDisplay();
		
		if (m_ItemList.selectedIndex != -1) {
			var setName:String = m_ItemList.dataProvider[m_ItemList.selectedIndex].m_ItemName;
			Chat.SignalShowFIFOMessage.Emit("Valet: " + setName, 0);
			m_ClothingDeckManagerImpl.equipClothingSet(setName);
		}
	}
	
	public function InitList() {
		
		var array:Array = m_ClothingDeckManagerImpl.getClothingSetList();
		m_ItemList.dataProvider = [];
		
		for (var childIdx:Number = 0; childIdx < array.length; ++childIdx) {
			var name:String = array[childIdx];
			if (name != null && name != undefined && name.length > 0 && MatchFilter(name)) {
				var listItem:Object = new Object;
			
		    	listItem.m_ItemName = name;
				listItem.m_IsEquipped = false;
				listItem.m_NodeIdx = childIdx;
				listItem.m_IsContainer = false;
				m_ItemList.dataProvider.push( listItem );
			}
		}
        m_ItemList.invalidateData();
	}
	
	private function MatchFilter(name:String):Boolean {
		var searchText:String = m_FilterBox.GetSearchText().toLowerCase();
		if (searchText.length == 0) {
			return true;
		}
		name = name.toLowerCase();
		
		var searchSplit:Array = searchText.split(" ");
		for (var idx:Number = 0; idx < searchSplit.length; ++idx) {
			var searchFilter = searchSplit[idx];
			if (searchFilter == null || searchFilter.length == 0)
				continue;
			if (name.indexOf(searchFilter) == -1) {
				return false;
			}
		}
		return true;
	}
	
	// used to set translations
	// not character dependent
	// will need update for new translations
	private function InitStaticData() {
		
		var languageCode:String =  LDBFormat.GetCurrentLanguageCode();
		
		if (languageCode == "de") {
			renameHeadline = "OUTFIT UMBENENNEN";
			overwriteHeadline = "OUTFIT UPDATEN";
			createHeadline = "OUTFIT SPEICHERN";
			deleteHeadline = "OUTFIT LÖSCHEN";
			copyHeadline = "OUTFIT KOPIEREN";
			
			renameText = "Wie soll das Outfit jetzt heissen?";
			overwriteText = "Soll das gespeicherte Outfit mit der aktuellen Kleidung überschrieben werden?";
			createText = "Bitte einen Namen für das Outfit eingeben.";
			deleteText = "Soll das Outfit wirklich gelöscht werden?";
			copyText = createText;
		}
		
		if (languageCode == "fr") {
			renameHeadline = "RENOMMER LA TENUE";
			overwriteHeadline = "METTRE A JOUR";
			createHeadline = "SAUVER LA TENUE";
			deleteHeadline = "EFFACER LA TENUE";
			copyHeadline = "COPIER LA TENUE";
			
			renameText = "Saisissez le nouveau nom pour cette tenue.";
			overwriteText = "Mettre à jour cette tenue avec les vêtements que vous portez actuellement?";
			createText = "Saisissez le nom sous lequel vous voulez enregistrer votre tenue actuelle.";
			deleteText = "Voulez-vous vraiment supprimer cette tenue ?";
			copyText = "Saisissez le nom sous lequel vous voulez enregistrer cette tenue.";;
		}

		if (languageCode == "en") {
			renameHeadline = "RENAME OUTFIT";
			overwriteHeadline = "UPDATE OUTFIT";
			createHeadline = "SAVE OUTFIT";
			deleteHeadline = "DELETE OUTFIT";
			copyHeadline = "COPY OUTFIT";
			
			renameText = "What will be the new name for this outfit?";
			overwriteText = "Do you want to update this outfit with your currently equipped clothing?";
			createText = "Enter a name for this new outfit";
			deleteText = "Do you really want to delete this outfit?";
			copyText = createText;
		}
	}

	public function CloseWindow(eventObj:Object) {
		this.removeMovieClip();
		DistributedValue.SetDValue("Valet_OptionWindowOpen", false);
	}
	
	// Confirm Panel
	//Confirm Panel Move Drag Handler
    private function ConfirmPanelMoveDragHandler():Void
    {
        m_ConfirmPanel.startDrag();
    }
	
	//Confirm Panel Move Drag Release Handler
    private function ConfirmPanelMoveDragReleaseHandler():Void
    {
        m_ConfirmPanel.stopDrag();
    }
	
	//Close Confirmation Panel
	private function CloseConfirmationPanel():Void
	{
		var bounds:Object = this["m_ConfirmPanel"].getBounds(this);
		m_IsConfimationPanelOpen = false;
		m_ConfirmPanel.removeMovieClip();
	}
	
	//Misc
	private function RemoveFocus()
    {
        Selection.setFocus(null);
    }
}