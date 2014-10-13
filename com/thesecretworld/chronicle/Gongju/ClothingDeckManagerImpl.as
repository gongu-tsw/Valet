
import com.GameInterface.Inventory;
import com.GameInterface.InventoryItem;

import com.GameInterface.Chat;

import com.GameInterface.Game.Character;

import com.thesecretworld.chronicle.Gongju.ClothingDeck;

import com.Utils.Archive;

import com.Utils.ID32;

class com.thesecretworld.chronicle.Gongju.ClothingDeckManagerImpl {

	private var m_WardrobeInventory:Inventory; // character wardrobe
	private var m_EquippedInventory:Inventory; // character current clothes
	private var m_CurrentDefensiveTarget:ID32;
	private var m_WardrobeChanged:Boolean;
	private var m_EquippedChanged:Boolean;
	private var m_ClothingDeckArray:Array;
	
	static private var m_AllPlacement:Array = [
		_global.Enums.ItemEquipLocation.e_Wear_Face,
		_global.Enums.ItemEquipLocation.e_HeadAccessory,
		_global.Enums.ItemEquipLocation.e_Wear_Hat,
		_global.Enums.ItemEquipLocation.e_Wear_Neck,
		_global.Enums.ItemEquipLocation.e_Wear_Chest,
		_global.Enums.ItemEquipLocation.e_Wear_Back,
		_global.Enums.ItemEquipLocation.e_Wear_Hands,
		_global.Enums.ItemEquipLocation.e_Wear_Legs,
		_global.Enums.ItemEquipLocation.e_Wear_Feet,
		_global.Enums.ItemEquipLocation.e_Wear_FullOutfit
	];

	public function ClothingDeckManagerImpl() {
		m_WardrobeChanged = true;
		m_EquippedChanged = true;
		// clothing deck list loading done externaly for now
		m_ClothingDeckArray = new Array();
	}
	
	public function addClothingSet(name:String):String {
		for (var idx:Number = 0; idx < m_ClothingDeckArray.length; ++idx) {
			var deck:ClothingDeck = m_ClothingDeckArray[idx];
			if (deck.getName() == name)
				return "Error name already used";
		}
		
		if (name.indexOf("|") != -1)
			return "Error: | Not allowed in name";
		
		if (name == null || name == undefined || name.length == 0) {
			return "Invalid name";
		}

		addOrUpdateClothingSet(name, true);
    	
    	return undefined;
	}
	
	public function copyClothingSet(name:String):String {
		for (var idx:Number = 0; idx < m_ClothingDeckArray.length; ++idx) {
			var deck:ClothingDeck = m_ClothingDeckArray[idx];
			if (deck.getName() == name)
				return "Error name already used";
		}
		
		if (name.indexOf("|") != -1)
			return "Error: | Not allowed in name";
		
		if (name == null || name == undefined || name.length == 0) {
			return "Invalid name";
		}
		
		addOrUpdateClothingSet(name, true, true);
	}
	
	public function renameClothingSet(oldname:String, newname:String) {
		
		for (var idx:Number = 0; idx < m_ClothingDeckArray.length; ++idx) {
			var problemdeck:ClothingDeck = m_ClothingDeckArray[idx];
			if (problemdeck.getName() == newname) {
				return "Error: New name already in use";
			}
		}
		
		if (newname.indexOf("|") != -1)
			return "Error: | Not allowed in name";
		
		var deck:ClothingDeck = null;
		var found:Boolean = false;
		for (var idx:Number = 0; idx < m_ClothingDeckArray.length; ++idx) {
			deck = m_ClothingDeckArray[idx];
			if (deck.getName() == oldname) {
				found = true;
				break;
			}
		}
		
		if (!found) {
			return "Error: Set to edit not found";
		}
		
		deck.setName(newname);
	}
		
	public function updateClothingSet(name:String):String {
		var found:Boolean = false;
		for (var idx:Number = 0; idx < m_ClothingDeckArray.length; ++idx) {
			var deck:ClothingDeck = m_ClothingDeckArray[idx];
			if (deck.getName() == name) {
				found = true;
				break;
			}
		}
		
		if (!found) {
			return "Error name does not exist";
		}
		
		if (name == null || name == undefined || name.length == 0) {
			return "Invalid name";
		}

		addOrUpdateClothingSet(name, false);
    	
    	return undefined;
	}
	
	public function createClothingDeckFromTarget (inventory:Inventory, deck:ClothingDeck, deckName:String) : ClothingDeck {
		
		var headgear1:String = undefined;
    	var headgear2:String = undefined;
    	var hats:String = undefined;
    	var neck:String = undefined;
    	var chest:String = undefined;
    	var back:String = undefined;
    	var hands:String = undefined;
    	var leg:String = undefined;
    	var feet:String = undefined;
    	var multislot:String = undefined;
		
		for (var idx:Number = 0; idx < m_AllPlacement.length; ++idx) {
			var idxNumber = m_AllPlacement[idx];
			
			if (isNaN(idxNumber)) {
				Chat.SignalShowFIFOMessage.Emit("Error: ClothingDeckManagerImpl: AA:" + idxNumber , 0);
				continue;
			}
			
			switch(idxNumber) {
				case _global.Enums.ItemEquipLocation.e_Wear_Face:
					headgear1 = inventory.GetItemAt(idxNumber).m_Name;
					break;
				case _global.Enums.ItemEquipLocation.e_HeadAccessory:
					headgear2 = inventory.GetItemAt(idxNumber).m_Name;
					break;
				case _global.Enums.ItemEquipLocation.e_Wear_Hat:
					hats = inventory.GetItemAt(idxNumber).m_Name;
					break;
				case _global.Enums.ItemEquipLocation.e_Wear_Neck:
					neck = inventory.GetItemAt(idxNumber).m_Name;
					break;
				case _global.Enums.ItemEquipLocation.e_Wear_Chest:
					chest = inventory.GetItemAt(idxNumber).m_Name;
					break;
				case _global.Enums.ItemEquipLocation.e_Wear_Back:
					back = inventory.GetItemAt(idxNumber).m_Name;
					break;
				case _global.Enums.ItemEquipLocation.e_Wear_Hands:
					hands = inventory.GetItemAt(idxNumber).m_Name;
					break;
				case _global.Enums.ItemEquipLocation.e_Wear_Legs:
					leg = inventory.GetItemAt(idxNumber).m_Name;
					break;
				case _global.Enums.ItemEquipLocation.e_Wear_Feet:
					feet = inventory.GetItemAt(idxNumber).m_Name;
					break;
				case _global.Enums.ItemEquipLocation.e_Wear_FullOutfit:
					multislot = inventory.GetItemAt(idxNumber).m_Name;
					break;
			}
		}
		
		if (deck != null) {
			deck.update(headgear1, headgear2, hats, neck, chest, back, hands, leg, feet, multislot);
			return deck;
		} else {
			var charName = Character.GetClientCharacter().GetName();
			var newClothingDeck:ClothingDeck = new ClothingDeck(charName, deckName, headgear1, headgear2, hats, neck, chest, back, hands, leg, feet, multislot);
			return newClothingDeck
		}
	}
	
	private function addOrUpdateClothingSet(name:String, add:Boolean, targetCharacter:Boolean) {
		var currentInventory:Inventory;
		if (targetCharacter === true) {
			var characterID:ID32 = m_CurrentDefensiveTarget;
			currentInventory = new Inventory(new com.Utils.ID32(_global.Enums.InvType.e_Type_GC_WearInventory, characterID.GetInstance()));
		}
		else
		{
			updateInventories();
			currentInventory = m_EquippedInventory;
		}
		
		if (add) {
			var newClothingDeck = createClothingDeckFromTarget(currentInventory, null, name);
    		m_ClothingDeckArray.push(newClothingDeck);
		} else {
			// name existence already checked
			for (var idx:Number = 0; idx < m_ClothingDeckArray.length; ++idx) {
				var deck:ClothingDeck = m_ClothingDeckArray[idx];
				if (deck.getName() == name) {
					createClothingDeckFromTarget(currentInventory, deck, name);
					break;
				}
			}
		}
	}
	
	public function deleteClothingSet(name:String):String {
		for (var idx:Number = 0; idx < m_ClothingDeckArray.length; ++idx) {
			var deck:ClothingDeck = m_ClothingDeckArray[idx];
			if (deck.getName() == name) {
				m_ClothingDeckArray.splice(idx, 1);
				break;
			}
		}
		return undefined
	}
	
	public function getDeck(name:String):ClothingDeck {
		for (var idx:Number = 0; idx < m_ClothingDeckArray.length; ++idx) {
			var deck:ClothingDeck = m_ClothingDeckArray[idx];
			if (deck.getName() == name) {
				return deck;
			}
		}
		return undefined
	}
	
	public function equipClothingSet(name:String):String {
		var found:Boolean = false;
		var clothingDeck:ClothingDeck = null;
		for (var idx:Number = 0; idx < m_ClothingDeckArray.length; ++idx) {
			clothingDeck = m_ClothingDeckArray[idx];
			if (clothingDeck.getName() == name) {
				found = true;
				break;
			}
		}
		
		if (!found) {
			var languageCode:String = com.Utils.LDBFormat.GetCurrentLanguageCode();
			if (languageCode == "fr") {
				Chat.SignalShowFIFOMessage.Emit("Valet: Erreur: La tenue " + name + " est introuvable.", 0);
				com.GameInterface.Utils.PrintChatText("Valet: Erreur: La tenue " + name + " est introuvable.");
			} else if (languageCode == "de") {
				Chat.SignalShowFIFOMessage.Emit("Valet: Fehler: " + name + " nicht gefunden.", 0);
				com.GameInterface.Utils.PrintChatText("Valet: Fehler: " + name + " nicht gefunden.");
			} else { // default english
				Chat.SignalShowFIFOMessage.Emit("Valet: Error: The outfit " + name + " was not found.", 0);
				com.GameInterface.Utils.PrintChatText("Valet: Error: The outfit " + name + " was not found");
			}
			return "Error name does not exist";
		}
		
		updateInventories();
		
		var waitValue:Number = 0;
		
		for (var idxIt:Number = 0; idxIt < m_AllPlacement.length; ++idxIt) {
			var idx:Number = m_AllPlacement[idxIt];
			var invItem:InventoryItem = m_EquippedInventory.GetItemAt(idx);
			var equippedItemName = undefined;
			if (invItem) {
				equippedItemName = invItem.m_Name;
			}
			var deckItemName = clothingDeck.getElementNameByEnumIdx(idx);
			
			
			if (deckItemName == equippedItemName) { // nothing to do for this placement
				continue;
			}
			if (deckItemName == undefined || deckItemName == null || deckItemName == "") {
				
				if (equippedItemName == undefined || equippedItemName == null || equippedItemName == "") {
					continue; // nothing to do
				}
				else {
					if (CanLocationBeUnequipped(idx)) {
						_global['setTimeout'](this,'removeClothingFromPlacement', waitValue, idx);
						waitValue = waitValue + 250;
					}
				}
			}
			else {
				_global['setTimeout'](this,'equipClothingFromName', waitValue, deckItemName, idx);
				waitValue = waitValue + 250;
			}
		}
	}
	
	public function equipClothingFromName (itemName:String, placement:Number) {
		updateInventories();
		var found = false;
		for (var idx:Number = 0; idx < m_WardrobeInventory.GetMaxItems(); ++idx) {
			var itemFromWardrobe:InventoryItem = m_WardrobeInventory.GetItemAt(idx);
			if (itemFromWardrobe && itemFromWardrobe.m_Name == itemName) {
				m_EquippedInventory.AddItem( m_WardrobeInventory.m_InventoryID, idx,
					_global.Enums.ItemEquipLocation.e_Wear_DefaultLocation );
				found = true;
				break;
			}
		}
		
		if (!found) {
			var languageCode:String = com.Utils.LDBFormat.GetCurrentLanguageCode();
			
			if (languageCode == "fr") {
				Chat.SignalShowFIFOMessage.Emit("Valet: Erreur: Le vêtement " + itemName + " est introuvable.", 0);
				com.GameInterface.Utils.PrintChatText("Valet: Erreur: Le vêtement " + itemName + " est introuvable.")
			} else if (languageCode == "de") {
				Chat.SignalShowFIFOMessage.Emit("Valet: Fehler: " + itemName + " nicht gefunden.", 0);
				com.GameInterface.Utils.PrintChatText("Valet: Fehler: " + itemName + " nicht gefunden.")
			} else {
				Chat.SignalShowFIFOMessage.Emit("Valet: Error: Clothing " + itemName + " was not found.", 0);
				com.GameInterface.Utils.PrintChatText("Valet: Error: Clothing " + itemName + " was not found")
			}
		}
	}
	
	public function removeClothingFromPlacement (placement:Number) {
		updateInventories();
		m_WardrobeInventory.AddItem(m_EquippedInventory.m_InventoryID,
										placement,
										_global.Enums.ItemEquipLocation.e_Wear_DefaultLocation);
	}
	
	// Moving outfit in list functions
	
	public function moveClothingToTop ( itemName:String) {
		for (var idx:Number = 0; idx < m_ClothingDeckArray.length; ++idx) {
			var deck:ClothingDeck = m_ClothingDeckArray[idx];
			var deckName = deck.getName();
			if ( itemName == deckName ) {
				if (idx != 0) {
					var toMove:Array = m_ClothingDeckArray.splice(idx,1);
					m_ClothingDeckArray.unshift(toMove[0]);
				}
				break;
			}
		}
	}
	
	public function moveClothingUp ( itemName:String) {
		for (var idx:Number = 0; idx < m_ClothingDeckArray.length; ++idx) {
			var deck:ClothingDeck = m_ClothingDeckArray[idx];
			var deckName = deck.getName();
			if ( itemName == deckName ) {
				if (idx != 0) {
					var toMove:Array = m_ClothingDeckArray.splice(idx,1);
					m_ClothingDeckArray.splice(idx - 1, 0, toMove[0]);
				}
				break;
			}
		}
	}
	
	public function moveClothingToBottom ( itemName:String) {
		for (var idx:Number = 0; idx < m_ClothingDeckArray.length; ++idx) {
			var deck:ClothingDeck = m_ClothingDeckArray[idx];
			var deckName = deck.getName();
			if ( itemName == deckName ) {
				if (idx != m_ClothingDeckArray.length - 1) {
					var toMove:Array = m_ClothingDeckArray.splice(idx,1);
					m_ClothingDeckArray.push(toMove[0]);
				}
				break;
			}
		}
	}
	
	public function moveClothingDown ( itemName:String) {
		for (var idx:Number = 0; idx < m_ClothingDeckArray.length; ++idx) {
			var deck:ClothingDeck = m_ClothingDeckArray[idx];
			var deckName = deck.getName();
			if ( itemName == deckName ) {
				if (idx != m_ClothingDeckArray.length - 1) {
					var toMove:Array = m_ClothingDeckArray.splice(idx,1);
					m_ClothingDeckArray.splice(idx + 1, 0, toMove[0]);
				}
				break;
			}
		}
	}
	
	public function getClothStatus(clothName:String) : Number {
		var clientCharacterID:ID32 = Character.GetClientCharID();
		var m_EquippedInventory = new Inventory( new com.Utils.ID32(_global.Enums.InvType.e_Type_GC_WearInventory, clientCharacterID.GetInstance()) );
		
		for ( var i:Number = 0 ; i < m_EquippedInventory.GetMaxItems() ; ++i ) {
			var invItem:InventoryItem = m_EquippedInventory.GetItemAt(i);
			if ( invItem.m_Name == clothName) {
				return 2;
			}
		}
		
		var m_WardrobeInventory = new Inventory( new com.Utils.ID32(_global.Enums.InvType.e_Type_GC_StaticInventory, clientCharacterID.GetInstance()) );
		for ( var i:Number = 0 ; i < m_WardrobeInventory.GetMaxItems() ; ++i ) {
			var invItem:InventoryItem = m_WardrobeInventory.GetItemAt(i);
			if ( invItem.m_Name == clothName) {
				return 1;
			}
		}
		
		return 0;
	}
	
	public function getClothingSetList():Array {
		var returnArray:Array = [];
		
		for (var idx:Number = 0; idx < m_ClothingDeckArray.length; ++idx) {
			var deck:ClothingDeck = m_ClothingDeckArray[idx];
			var name = deck.getName();
			returnArray.push(name);
		}
	
		return returnArray;
	}
	
	// Misc
	public function setDefensiveTarget(newDefensiveTarget:ID32) {
		m_CurrentDefensiveTarget = newDefensiveTarget;
	}
	
	private function updateInventories() {
		var clientCharacterID:ID32 = Character.GetClientCharID();
		if (m_WardrobeChanged) {
			m_WardrobeInventory = new Inventory(new com.Utils.ID32(_global.Enums.InvType.e_Type_GC_StaticInventory, clientCharacterID.GetInstance()));
			m_WardrobeChanged = false;
			
			m_WardrobeInventory.SignalItemAdded.Connect( onWardrobeChange, this );
        	m_WardrobeInventory.SignalItemChanged.Connect( onWardrobeChange, this );
        	m_WardrobeInventory.SignalItemRemoved.Connect( onWardrobeChange, this );
		}
		if (m_EquippedChanged) {
			m_EquippedInventory = new Inventory(new com.Utils.ID32(_global.Enums.InvType.e_Type_GC_WearInventory, clientCharacterID.GetInstance()));
			m_EquippedChanged = false;
			
			m_EquippedInventory.SignalItemAdded.Connect( onEquippedChange, this );
        	m_EquippedInventory.SignalItemChanged.Connect( onEquippedChange, this );
        	m_EquippedInventory.SignalItemRemoved.Connect( onEquippedChange, this );
		}
	}
	
	public function PreviewAllFromTarget(){
		Chat.SignalShowFIFOMessage.Emit("DEBUG: PreviewAllFromTarget", 0);
		
		var characterID:ID32 = m_CurrentDefensiveTarget;
		var targetInventory:Inventory = new Inventory(new com.Utils.ID32(_global.Enums.InvType.e_Type_GC_WearInventory, characterID.GetInstance()));
		var previewOK:Boolean = targetInventory.PreviewCharacter(m_CurrentDefensiveTarget);
		//m_PreviewAllButton.disabled = !previewOK;
    }
	
	public function onWardrobeChange() {
		m_WardrobeChanged = true;
	}
	
	public function onEquippedChange() {
		m_EquippedChanged = true;
	}
	
	public function addSerializedDeck(deckArchive:Archive) {
		var charName:String = deckArchive.FindEntry("charName", undefined);
		var name:String = deckArchive.FindEntry("name", undefined);
		var headgear1:String = deckArchive.FindEntry("headgear1", undefined);
    	var headgear2:String = deckArchive.FindEntry("headgear2", undefined);
    	var hats:String = deckArchive.FindEntry("hats", undefined);
    	var neck:String = deckArchive.FindEntry("neck", undefined);
    	var chest:String = deckArchive.FindEntry("chest", undefined);
    	var back:String = deckArchive.FindEntry("back", undefined);
    	var hands:String = deckArchive.FindEntry("hands", undefined);
    	var leg:String = deckArchive.FindEntry("leg", undefined);
    	var feet:String = deckArchive.FindEntry("feet", undefined);
    	var multislot:String = deckArchive.FindEntry("multislot", undefined);
    	
    	var newClothingDeck:ClothingDeck = new ClothingDeck(charName, name, headgear1, headgear2, hats, neck, chest, back, hands, leg, feet, multislot);
    	m_ClothingDeckArray.push(newClothingDeck);
    	
	}
	
	public function exportAllDecks():String
	{
		var export = "VALET_EXPORT;0.5%HEAD%"
		for (var idx:Number = 0; idx < m_ClothingDeckArray.length; ++idx) {
			var deck:ClothingDeck = m_ClothingDeckArray[idx];
			
			if (idx != 0)
				export = export + "%O%";
				
			export = export + deckExportString(deck);
		}
		return export;
	}
	
	public function exportSelectedDeck(itemName:String):String
	{
		var export = "VALET_EXPORT;0.5%HEAD%"
		for (var idx:Number = 0; idx < m_ClothingDeckArray.length; ++idx) {
			var deck:ClothingDeck = m_ClothingDeckArray[idx];
			var deckName = deck.getName();
			if ( itemName == deckName ) {
				
				export = export + deckExportString(deck);
				
				break;
			}
		}
		return export;
	}
	
	public function deckExportString(deck:ClothingDeck):String
	{
		return deck.getName() + "|" + deck.getFeet() + "|" + deck.getLeg() + "|" +
			deck.getChest() + "|" + deck.getBack() + "|" + deck.getHands() + "|" + deck.getNeck() + "|" +
			deck.getHats() + "|" + deck.getHeadgear1() + "|" + deck.getHeadgear2() + "|" +
			deck.getMultislot() + "|false|undefined" ;"|false|undefined" ;
	}
	
	public function importDecks(importString:String)
	{
		var headIdx:Number = importString.indexOf("%HEAD%");
		if (headIdx != -1) {
			var charName = Character.GetClientCharacter().GetName();
			var header:String = importString.substring(0,headIdx);
			// should be compatible with fashionista 2.1 VFA_EXPORT;2.1
			importString = importString.substring(headIdx + 6);
			var outfits:Array = importString.split('%0%');
			var nbOutfits = outfits.length;
			for (var idx:Number = 0; idx < nbOutfits; idx++) {
				var outfitString:String = outfits[idx];
				var singleOutfitArray = outfitString.split("|");
				var name:String = singleOutfitArray[0];
				
				var found:Boolean = false;
				for (var clothingDeckIdx:Number = 0; clothingDeckIdx < m_ClothingDeckArray.length; ++clothingDeckIdx) {
					var deck:ClothingDeck = m_ClothingDeckArray[clothingDeckIdx];
					var deckName = deck.getName();
					if ( name == deckName ) {
						found = true;
						break;
					}
				}
				if (found) {
					// make some warning about not imported outfit
					continue;
				}
				
				var headgear1:String = singleOutfitArray[8];
				var headgear2:String = singleOutfitArray[9];
				var hats:String = singleOutfitArray[7];
				var neck:String = singleOutfitArray[6];
				var chest:String = singleOutfitArray[3];
				var back:String = singleOutfitArray[4];
				var hands:String = singleOutfitArray[5];
				var leg:String = singleOutfitArray[2];
				var feet:String = singleOutfitArray[1];
				var multislot:String = singleOutfitArray[10];
				var favorite:String = singleOutfitArray[11]; // unused
				var outfitId:String = singleOutfitArray[12]; // unused
				
				// TODO name already exist ?
				// if yes, what ?
				var newClothingDeck:ClothingDeck = new ClothingDeck(charName, name, headgear1, headgear2, hats, neck, chest, back, hands, leg, feet, multislot);
			}
		}
	}
	
	
	public function serializeAllDeck():Array
	{
		var serializedDeckArray:Array = [];
		
		for (var idx:Number = 0; idx < m_ClothingDeckArray.length; ++idx) {
			var deck:ClothingDeck = m_ClothingDeckArray[idx];
			var deckArchive:Archive = serializeDeck(deck);
			serializedDeckArray.push(deckArchive);
		}
		
		return serializedDeckArray;
	}
	
	private function serializeDeck(deck:ClothingDeck):Archive{
		var deckArchive:Archive = new Archive();
		
		deckArchive.AddEntry("name", deck.getName());
		if (deck.getHeadgear1() != undefined) {
			deckArchive.AddEntry("headgear1", deck.getHeadgear1());
		}
		if (deck.getHeadgear2() != undefined) {
    		deckArchive.AddEntry("headgear2", deck.getHeadgear2());
		}
		if (deck.getHats() != undefined) {
    		deckArchive.AddEntry("hats", deck.getHats());
		}
		if (deck.getNeck() != undefined) {
			deckArchive.AddEntry("neck", deck.getNeck());
		}
		if (deck.getChest() != undefined) {
			deckArchive.AddEntry("chest", deck.getChest());
		}
		if (deck.getBack() != undefined) {
			deckArchive.AddEntry("back", deck.getBack());
		}
		if (deck.getHands() != undefined) {
    		deckArchive.AddEntry("hands", deck.getHands());
		}
		if (deck.getLeg() != undefined) {
			deckArchive.AddEntry("leg", deck.getLeg());
		}
		if (deck.getFeet() != undefined) {
			deckArchive.AddEntry("feet", deck.getFeet());
		}
		if (deck.getMultislot() != undefined) {
			deckArchive.AddEntry("multislot", deck.getMultislot());
		}
	
		return deckArchive;
	}
	
	// Utils
	
	private function CanLocationBeUnequipped( location:Number ) : Boolean {
		return location != _global.Enums.ItemEquipLocation.e_Wear_Chest && location != _global.Enums.ItemEquipLocation.e_Wear_Legs;
	}

}