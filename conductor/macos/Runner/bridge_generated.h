#include <stdbool.h>
#include <stdint.h>
#include <stdlib.h>
typedef struct _Dart_Handle* Dart_Handle;

typedef struct DartCObject DartCObject;

typedef int64_t DartPort;

typedef bool (*DartPostCObjectFnType)(DartPort port_id, void *message);

typedef struct wire_uint_8_list {
  uint8_t *ptr;
  int32_t len;
} wire_uint_8_list;

typedef struct wire_RwLockRawSpeaker {
  const void *ptr;
} wire_RwLockRawSpeaker;

typedef struct DartCObject *WireSyncReturn;

void store_dart_post_cobject(DartPostCObjectFnType ptr);

Dart_Handle get_dart_object(uintptr_t ptr);

void drop_dart_object(uintptr_t ptr);

uintptr_t new_dart_opaque(Dart_Handle handle);

intptr_t init_frb_dart_api_dl(void *obj);

void wire_speaker_new(int64_t port_, struct wire_uint_8_list *ip);

void wire_speaker_connect(int64_t port_, struct wire_RwLockRawSpeaker x);

void wire_speaker_is_connected(int64_t port_, struct wire_RwLockRawSpeaker x);

void wire_speaker_get_info(int64_t port_, struct wire_RwLockRawSpeaker x);

struct wire_RwLockRawSpeaker new_RwLockRawSpeaker(void);

struct wire_uint_8_list *new_uint_8_list_0(int32_t len);

void drop_opaque_RwLockRawSpeaker(const void *ptr);

const void *share_opaque_RwLockRawSpeaker(const void *ptr);

void free_WireSyncReturn(WireSyncReturn ptr);

static int64_t dummy_method_to_enforce_bundling(void) {
    int64_t dummy_var = 0;
    dummy_var ^= ((int64_t) (void*) wire_speaker_new);
    dummy_var ^= ((int64_t) (void*) wire_speaker_connect);
    dummy_var ^= ((int64_t) (void*) wire_speaker_is_connected);
    dummy_var ^= ((int64_t) (void*) wire_speaker_get_info);
    dummy_var ^= ((int64_t) (void*) new_RwLockRawSpeaker);
    dummy_var ^= ((int64_t) (void*) new_uint_8_list_0);
    dummy_var ^= ((int64_t) (void*) drop_opaque_RwLockRawSpeaker);
    dummy_var ^= ((int64_t) (void*) share_opaque_RwLockRawSpeaker);
    dummy_var ^= ((int64_t) (void*) free_WireSyncReturn);
    dummy_var ^= ((int64_t) (void*) store_dart_post_cobject);
    dummy_var ^= ((int64_t) (void*) get_dart_object);
    dummy_var ^= ((int64_t) (void*) drop_dart_object);
    dummy_var ^= ((int64_t) (void*) new_dart_opaque);
    return dummy_var;
}