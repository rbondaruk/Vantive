CREATE OR REPLACE PACKAGE ATSP_GET_EMPCODE_PKG IS

PROCEDURE ATSP_GET_EMPCODE
  (EmpId            IN     SW_PERSON.swPersonId%TYPE,
   ErrorCode        OUT    SW_VALID_CODE.swCode%TYPE,
   EmpCodeId        OUT    VARCHAR2,
   batch_size       IN     int,
   out_batch_size   IN OUT int,
   status           OUT    int);
END ATSP_GET_EMPCODE_PKG;
/

CREATE OR REPLACE PACKAGE BODY ATSP_GET_EMPCODE_PKG AS
PROCEDURE ATSP_GET_EMPCODE
  (EmpId           IN     SW_PERSON.swPersonId%TYPE,
   ErrorCode       OUT    SW_VALID_CODE.swCode%TYPE,
   EmpCodeId       OUT    VARCHAR2,
   batch_size      IN     int,
   out_batch_size  IN OUT int,
   status          OUT    int)
IS

CURSOR c1
  (EmpId           SW_PERSON.swPersonId%TYPE)

IS
   SELECT atEmpCodeId
   FROM AT_EMPLOYEE_CODE
   WHERE atEmployeeId = EmpId
   OR atBackupId = EmpId;

BEGIN

ErrorCode      := 0;
EmpCodeId      := NULL;
out_batch_size := 1;
status         := 0;

IF EmpId IS NULL THEN
   status    := 7316;
   ErrorCode := '7316';
   RETURN;
END IF;

FOR c1_rec IN c1 (EmpId)
LOOP
   BEGIN

   IF EmpCodeId IS NULL THEN
      EmpCodeId := c1_rec.atEmpCodeId;
   ELSIF LENGTH (EmpCodeId || ',' || c1_rec.atEmpCodeId) > 2000 THEN
      EXIT;
   ELSE
      EmpCodeId := EmpCodeId || ',' || c1_rec.atEmpCodeId;
   END IF;

   END;
END LOOP;

END  ATSP_GET_EMPCODE;
END  ATSP_GET_EMPCODE_PKG;
/

