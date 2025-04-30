#ifndef SLYDriverIPCMessages_h
#define SLYDriverIPCMessages_h

static const uint32_t SLYDriverProtocolVersion_v1 = 1;
static const uint32_t SLYDriverProtocolCurrentVersion = SLYDriverProtocolVersion_v1;

typedef enum {
    SLYDriverDeviceInputReportMessageID,
	SLYDriverErrorMessageID,
    SLYDriverMessageCount,
} SLYDriverMessageID;

typedef enum {
    SLYDriverUnknownError,
} ACErrorCode;

typedef struct __attribute__((packed)) {
    SLYDriverMessageID MessageID;
} SLYDriverMessage;

typedef struct __attribute__((packed)) {
    SLYDriverMessage Header;
    uint8_t Reserved[8];
} SLYDriverDeviceInputReportMessage;

typedef struct __attribute__((packed)) {
    SLYDriverMessage Header;
    uint8_t Reserved[2];
} SLYDriverErrorMessage;

#endif /* SLYDriverIPCMessages_h*/
