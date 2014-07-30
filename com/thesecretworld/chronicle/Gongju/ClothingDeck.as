import com.GameInterface.Chat;
import com.GameInterface.Game.Character;
import com.GameInterface.Game.CharacterBase;

class com.thesecretworld.chronicle.Gongju.ClothingDeck {

	private var m_CharName:String;
	private var m_Name:String;
	private var m_Headgear1:String;
    private var m_Headgear2:String;
    private var m_Hats:String;
    private var m_Neck:String;
    private var m_Chest:String;
    private var m_Back:String;
    private var m_Hands:String;
    private var m_Leg:String;
    private var m_Feet:String;
    private var m_Multislot:String;
    
    static public var m_AllPlacement:Object = [
		_global.Enums.ItemEquipLocation.e_Wear_Face,
		_global.Enums.ItemEquipLocation.e_HeadAccessory, // previously e_Necklace
		_global.Enums.ItemEquipLocation.e_Wear_Hat,
		_global.Enums.ItemEquipLocation.e_Wear_Neck,
		_global.Enums.ItemEquipLocation.e_Wear_Chest,
		_global.Enums.ItemEquipLocation.e_Wear_Back,
		_global.Enums.ItemEquipLocation.e_Wear_Hands,
		_global.Enums.ItemEquipLocation.e_Wear_Legs,
		_global.Enums.ItemEquipLocation.e_Wear_Feet,
		_global.Enums.ItemEquipLocation.e_Wear_FullOutfit
	];
	
	public function ClothingDeck (charName:String, name:String, headGear1:String,
				headGear2:String, hats:String, neck:String,
				chest:String, back:String, hands:String, leg:String,
				feet:String, multislot:String) {
		m_CharName = charName;
		m_Name = name;
		m_Headgear1 = headGear1;
    	m_Headgear2 = headGear2;
    	m_Hats = hats;
    	m_Neck = neck;
    	m_Chest = chest;
    	m_Back = back;
    	m_Hands = hands;
    	m_Leg = leg;
    	m_Feet = feet;
    	m_Multislot = multislot;
	}
	
	public function getCharacterName():String { return m_CharName;}
	public function getName():String {return m_Name};
	public function getHeadgear1():String {return m_Headgear1};
	public function getHeadgear2():String {return m_Headgear2};
	public function getHats():String {return m_Hats};
	public function getNeck():String {return m_Neck};
	public function getChest():String {return m_Chest};
	public function getBack():String {return m_Back};
	public function getHands():String {return m_Hands};
	public function getLeg():String {return m_Leg};
	public function getFeet():String {return m_Feet};
	public function getMultislot():String {return m_Multislot};
	
	public function getElementNameByEnumIdx (idx:Number):String {
		switch(idx) {
			case _global.Enums.ItemEquipLocation.e_Wear_Face:
				return getHeadgear1();
				break
			case _global.Enums.ItemEquipLocation.e_HeadAccessory:
				return getHeadgear2();
				break;
			case _global.Enums.ItemEquipLocation.e_Wear_Hat:
				return getHats();
				break;
			case _global.Enums.ItemEquipLocation.e_Wear_Neck:
				return getNeck();
				break;
			case _global.Enums.ItemEquipLocation.e_Wear_Chest:
				return getChest();
				break;
			case _global.Enums.ItemEquipLocation.e_Wear_Back:
				return getBack();
				break;
			case _global.Enums.ItemEquipLocation.e_Wear_Hands:
				return getHands();
				break;
			case _global.Enums.ItemEquipLocation.e_Wear_Legs:
				return getLeg();
				break;
			case _global.Enums.ItemEquipLocation.e_Wear_Feet:
				return getFeet();
				break;
			case _global.Enums.ItemEquipLocation.e_Wear_FullOutfit:
				return getMultislot();
				break;
		}
		return undefined;
	}
	
	public function update(headGear1:String, headGear2:String, hats:String, neck:String,
		chest:String, back:String, hands:String, leg:String, feet:String, multislot:String) {
		m_Headgear1 = headGear1;
    	m_Headgear2 = headGear2;
    	m_Hats = hats;
    	m_Neck = neck;
    	m_Chest = chest;
    	m_Back = back;
    	m_Hands = hands;
    	m_Leg = leg;
    	m_Feet = feet;
    	m_Multislot = multislot;
		m_CharName = Character.GetClientCharacter().GetName();
	}
	
	public function displayItself() {
		Chat.SignalShowFIFOMessage.Emit("ClothingDeck headGear1:" + m_Headgear1, 0);
		Chat.SignalShowFIFOMessage.Emit("ClothingDeck headGear2:" + m_Headgear2, 0);
		Chat.SignalShowFIFOMessage.Emit("ClothingDeck hats:" + m_Hats, 0);
		Chat.SignalShowFIFOMessage.Emit("ClothingDeck neck:" + m_Neck, 0);
		Chat.SignalShowFIFOMessage.Emit("ClothingDeck chest:" + m_Chest, 0);
		Chat.SignalShowFIFOMessage.Emit("ClothingDeck back:" + m_Back, 0);
		Chat.SignalShowFIFOMessage.Emit("ClothingDeck hands:" + m_Hands, 0);
		Chat.SignalShowFIFOMessage.Emit("ClothingDeck leg:" + m_Leg, 0);
		Chat.SignalShowFIFOMessage.Emit("ClothingDeck feet:" + m_Feet, 0);
		Chat.SignalShowFIFOMessage.Emit("ClothingDeck multislot:" + m_Multislot, 0);
	}
	
	public function setName(name:String) {
		m_Name = name;
	}
}