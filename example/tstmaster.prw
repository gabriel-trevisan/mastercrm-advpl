#include "TOTVS.ch"
#include "Protheus.ch"
#include "parmtype.ch"

/*/{Protheus.doc} U_TSTMASTER
Script de teste de como usar a classe
@type function
@version 12.1.27 
@author gabriel.santos
@since 20/05/2021
/*/
FUNCTION U_TSTMASTER()

 Local oMaster
	Local cResult
	Local aHeaderStr := {}

	oMaster := MasterCRM():new()
    oMaster:login('email', 'senha', 'tenant')

	aAdd(aHeaderStr, "Integration-Service: customer")
	aAdd(aHeaderStr, "Integration-Resource: customers-integration")
	aAdd(aHeaderStr, "Integration-Version: v2")
	aAdd(aHeaderStr, "Integration-Filter: {id->eq->f969b813-d409-421a-8e45-b838af0e8eb9}")

    /*
        Exemplo de Integration-Filter (Filtro RestQuery)
        {externalId->isNull}
        {active->eq->true}
        {externalId->eq->182406#01}
    */

	cResult := oMaster:clientes(aHeaderStr)

Return 
