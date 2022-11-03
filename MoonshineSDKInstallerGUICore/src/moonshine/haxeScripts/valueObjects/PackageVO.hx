package moonshine.haxeScripts.valueObjects;

import feathers.data.ArrayCollection;

class PackageVO 
{
    public var title:String;
    public var description:String;
    public var imagePath:String;
    public var isIntegrated:Bool;

    public function new() 
    {
        
    }

    //--------------------------------------------------------------------------
    //
    //  GETTERS/SETTERS
    //
    //--------------------------------------------------------------------------

    private var _dependencyTypes:ArrayCollection<ComponentVO>;
    public var dependencyTypes(get, set):ArrayCollection<ComponentVO>;
    private function set_dependencyTypes(value:ArrayCollection<ComponentVO>):ArrayCollection<ComponentVO>
    {
        _dependencyTypes = value;
        return value;
    }
    private function get_dependencyTypes():ArrayCollection<ComponentVO>
    {
        return _dependencyTypes;
    }
}