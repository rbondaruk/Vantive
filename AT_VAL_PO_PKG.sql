CREATE OR REPLACE PACKAGE ATSP_VAL_PO_PKG IS

PROCEDURE ATSP_VAL_PO
  (SOLId           IN     SW_PO_LINE_VW.swServiceOrdLnId%Type,
   ErrorCode        OUT    SW_VALID_CODE.swCode%TYPE,
   batch_size       IN     int,
   out_batch_size   IN OUT int,
   status           OUT    int);
END ATSP_VAL_PO_PKG;
/

/******************************************************************************

   Author                          	: Robert Bondaruk, PeopleSoft Consulting
   Date Written                    	: 08/02/2000
   Objects invoking this procedure 	: Purchase Order Line
   Events Called from              	: Field Changed Event
   Detailed Description            	:
      This proc checks to verify that there haven't been any reciepts against
	  a po.  If there have been receipts, the proc returns an error message
	  warning the user that they cannot make changes to the PO line.  It is
	  called by a vba script on the Open Record event of the Service Order
	  Line screen.
	  
   Modified By                     	:
   Modified Date                   	:
   Modified Desc.                   :

******************************************************************************/

CREATE OR REPLACE PACKAGE BODY ATSP_VAL_PO_PKG AS
PROCEDURE ATSP_VAL_PO
  (SOLId           IN     SW_PO_LINE_VW.swServiceOrdLnId%Type,
   ErrorCode       OUT    SW_VALID_CODE.swCode%TYPE,
   batch_size      IN     int,
   out_batch_size  IN OUT int,
   status          OUT    int)
IS

Quantity SW_PO_LINE_VW.swOrigQuantity%type;

BEGIN

out_batch_size := 1;
status         := 0;

IF SOLId IS NULL THEN
   status    := 7316;
   ErrorCode := '7316';
   RETURN;
END IF;
BEGIN
   SELECT nvl(SUM(S.swPendCloseQty),0)
   INTO Quantity
   FROM SW_SHIPMENT S
   WHERE S.swServiceOrdLnId = SOLId;
      EXCEPTION WHEN no_data_found THEN
      BEGIN
         status    := 0;
         ErrorCode := '0';
		 RETURN;
      END;
      WHEN others THEN
      BEGIN
         status    := -1;
		 ErrorCode := '-1';
		 RETURN;
      END;
END;

IF Quantity = 0 then
   status    := 0;
   ErrorCode := '0';
ELSE
   status    := 8196;
   ErrorCode := '8196';
END IF;

END  ATSP_VAL_PO;
END  ATSP_VAL_PO_PKG;
/

