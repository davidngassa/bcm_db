CREATE TABLE BCM_ORDER(
    ORDER_ID RAW(16) DEFAULT SYS_GUID(),
    ORDER_REF VARCHAR2(10),
    ORDER_DESCRIPTION VARCHAR2(255),
    ORDER_DATE DATE,
    ORDER_TOTAL_AMOUNT NUMBER,
    ORDER_STATUS VARCHAR2(10),
    SUPPLIER_ID RAW(16),
    PRIMARY KEY(ORDER_ID),
    CONSTRAINT FK_ORDER_SUPPLIER
        FOREIGN KEY (SUPPLIER_ID)
        REFERENCES BCM_SUPPLIER(SUPPLIER_ID)
);