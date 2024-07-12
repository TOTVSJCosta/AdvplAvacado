#include "totvs.ch"
#include "FWMVCDef.ch"

static function ModelDef()
    local oStruZZ2  := FwFormStruct(1, "ZZ2")
    local oModel    := MPFormModel():New("MD_ZZ2")

    oModel:AddFields("ZZ2MASTER", nil, oStruZZ2)
    oModel:SetPrimaryKey({"ZZ2_FILIAL", "ZZ2_ID"})


    oModel:SetDescription("Histórico")
    oModel:GetModel("ZZ2MASTER"):SetDescription("Histórico das Integrações")
return oModel
