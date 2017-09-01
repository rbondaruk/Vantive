CREATE OR REPLACE PACKAGE ATSP_CAT_QTY_PKG IS

PROCEDURE ATSP_CAT_QTY
  (POLId            IN     SW_PO_LINE_VW.swServiceOrdLnId%TYPE,
   POLQty           IN     SW_PO_LINE_VW.swOrigQuantity%TYPE,
   ItemId           IN     SW_PO_LINE_VW.swItemId%TYPE,
--   ErrorCode        OUT    SW_VALID_CODE.swCode%TYPE,
   batch_size       IN     int,
   out_batch_size   IN OUT int,
   status           OUT    int);
END ATSP_CAT_QTY_PKG;
/

/******************************************************************************

   Author                          	: Robert Bondaruk, PeopleSoft Consulting
   Date Written                    	: 08/02/2000
   Objects invoking this procedure 	: Purchase Order Line
   Events Called from              	: Field Changed Event
   Detailed Description            	:
      This proc checks to verify that Quanityt on the PO Line is greater than
	  or equal to the quantity on the Item Catalog for the part being procured.
	  If the quantity type on the SOL is less than the Quantity specified on
	  the Item Catalog the user is presented with and error message.
   Modified By                     	:
   Modified Date                   	:
   Modified Desc.                   :

******************************************************************************/

CREATE OR REPLACE PACKAGE BODY ATSP_CAT_QTY_PKG AS
PROCEDURE ATSP_CAT_QTY
  (POLId           IN     SW_PO_LINE_VW.swServiceOrdLnId%TYPE,
   POLQty          IN     SW_PO_LINE_VW.swOrigQuantity%TYPE,
   ItemId          IN     SW_PO_LINE_VW.swItemId%TYPE,
--   ErrorCode       OUT    SW_VALID_CODE.swCode%TYPE,
   batch_size      IN     int,
   out_batch_size  IN OUT int,
   status          OUT    int)
IS

OrderQty SW_ITEM_CATALOG.swMinOrder%TYPE;
MultiQty SW_ITEM_CATALOG.atMultiOrderQty%TYPE;

BEGIN

out_batch_size := 0;
status         := 0;

IF POLId IS NULL THEN
   status    := 7316;
--   ErrorCode := '7316';
   RETURN;
END IF;

IF POLQty IS NULL THEN
   status    := 7316;
--   ErrorCode := '7316';
   RETURN;
END IF;

IF ItemId IS NULL THEN
   status    := 7316;
--   ErrorCode := '7316';
   RETURN;
END IF;

BEGIN
   SELECT nvl(IC.swMinOrder,0),nvl(IC.atMultiOrderQty,0)
   INTO OrderQty,MultiQty
   FROM SW_ITEM_CATALOG IC, SW_SHIPMENT S
   WHERE S.swItemMasterId = ItemId
   AND S.swServiceOrdLnId = POLId
   AND S.swItemCatalogId = IC.swItemCatalogId;
      EXCEPTION WHEN no_data_found THEN
      BEGIN
         status    := 0;
--         ErrorCode := '0';
		 RETURN;
      END;
      WHEN others THEN
      BEGIN
         OUT_BATCH_SIZE := 0;
         status    := -1;
--		 ErrorCode := '-1';
		 RETURN;
      END;
END;

--IF Quantity = 0 then
--   status    := 0;
--   ErrorCode := '0';
--ELSE
--   status    := 8196;
--   ErrorCode := '8196';
--END IF;

END  ATSP_CAT_QTY;
END  ATSP_CAT_QTY_PKG;
/

