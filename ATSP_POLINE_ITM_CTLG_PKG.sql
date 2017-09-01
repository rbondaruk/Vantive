CREATE OR REPLACE PACKAGE ATSP_POLINE_ITM_CTLG_PKG IS

Procedure atsp_poline_itm_ctlg (ITMCTLGID IN SW_ITEM_CATALOG.SWITEMCATALOGID%TYPE,
--		  					   	PartNo    OUT SW_ITEM_CATALOG.SWPARTNUMBER%TYPE,
								ITMID	  OUT SW_ITEM_MASTER.SWITEMMASTERID%TYPE,
								MAXORD	  OUT SW_ITEM_CATALOG.SWMAXORDER%TYPE,
								MINORD	  OUT SW_ITEM_CATALOG.SWMINORDER%TYPE,
								MULTIORD  OUT SW_ITEM_CATALOG.ATMULTIORDERQTY%TYPE,
								BATCH_SIZE     	IN    int,
								OUT_BATCH_SIZE 	IN OUT int,
								STATUS         	OUT   int);
END ATSP_POLINE_ITM_CTLG_PKG;
/

/******************************************************************************

   Author                          	: ?
   Date Written                    	: ?
   Objects invoking this procedure 	: Purchase Order Line
   Events Called from              	: Derivation
   Detailed Description            	:
      This proc derives data to be displayed on the screen based on the Item
	  Catalog record the user has select to purchase.	  
   Modified By                     	: Robert Bondaruk, PeopleSoft Consulting
   Modified Date                   	: 8/8/2000
   Modified Desc.                   : 
      Modified the first returned parameter of the proc to return the Item
	  Master ItemCode and not the Item Catalog PartNumber. 

******************************************************************************/

CREATE OR REPLACE PACKAGE BODY ATSP_POLINE_ITM_CTLG_PKG AS
Procedure atsp_poline_itm_ctlg (ITMCTLGID IN SW_ITEM_CATALOG.SWITEMCATALOGID%TYPE,
--		  					   	PartNo    OUT SW_ITEM_CATALOG.SWPARTNUMBER%TYPE,
								ITMID	  OUT SW_ITEM_MASTER.SWITEMMASTERID%TYPE,
								MAXORD	  OUT SW_ITEM_CATALOG.SWMAXORDER%TYPE,
								MINORD	  OUT SW_ITEM_CATALOG.SWMINORDER%TYPE,
								MULTIORD  OUT SW_ITEM_CATALOG.ATMULTIORDERQTY%TYPE,
								BATCH_SIZE     	IN    int,
								OUT_BATCH_SIZE 	IN OUT int,
								STATUS         	OUT   int) IS
BEGIN



--select a.swPartNumber,b.swItemMasterId,NVL(a.swMaxOrder,0),NVL(a.swMinOrder,0),NVL(a.atMultiOrderQty,0)
select b.swItemMasterId,NVL(a.swMaxOrder,0),NVL(a.swMinOrder,0),NVL(a.atMultiOrderQty,0)
--INTO PARTNO,ITMID,MAXORD,MINORD,MULTIORD  from SW_ITEM_CATALOG a,SW_ITEM_CAT_MASTER b
INTO ITMID,MAXORD,MINORD,MULTIORD  from SW_ITEM_CATALOG a,SW_ITEM_CAT_MASTER b
where a.switemcatalogid = b.switemcatalogid and a.swItemCatalogId = nvl(ITMCTLGID,-1);



OUT_BATCH_SIZE := 1;
STATUS :=0;



   EXCEPTION
     WHEN NO_DATA_FOUND THEN
--      PARTNO := to_number(Null);
	  ITMID := to_number(Null);
	  MAXORD :=TO_NUMBER(NULL);
	  MINORD :=TO_NUMBER(NULL);
	  MULTIORD :=TO_NUMBER(NULL);
	  out_batch_size := 1;
	  status := -1;

	WHEN OTHERS THEN
	    OUT_BATCH_SIZE := 0;
		STATUS := -1;


END ATSP_POLINE_ITM_CTLG;
END ATSP_POLINE_ITM_CTLG_PKG;
/

