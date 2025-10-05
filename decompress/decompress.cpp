#include "../inc/crn_decomp.h"

using namespace crnd;

extern "C" {

    uint32 crunch_format_to_fourcc(crn_format fmt) {
        return crnd_crn_format_to_fourcc(fmt);
    }

    crn_format crunch_get_fundamental_dxt_format(crn_format fmt) {
        return crnd_get_fundamental_dxt_format(fmt);
    }

    uint32 crunch_get_crn_format_bits_per_texel(crn_format fmt) {
        return crnd_get_crn_format_bits_per_texel(fmt);
    }

    uint32 crunch_get_bytes_per_dxt_block(crn_format fmt) {
        return crnd_get_bytes_per_dxt_block(fmt);
    }

    bool crunch_validate_file(const void* pData, uint32 data_size, crn_file_info* pFile_info) {
        return crnd_validate_file(pData, data_size, pFile_info);
    }

    bool crunch_get_texture_info(const void* pData, uint32 data_size, crn_texture_info* pTexture_info) {
        return crnd_get_texture_info(pData, data_size, pTexture_info);
    }

    bool crunch_get_level_info(const void* pData, uint32 data_size, uint32 level_index, crn_level_info* pLevel_info) {
        return crnd_get_level_info(pData, data_size, level_index, pLevel_info);
    }

    crnd_unpack_context crunch_unpack_begin(const void* pData, uint32 data_size) {
        return crnd_unpack_begin(pData, data_size);
    }

    bool crunch_get_data(crnd_unpack_context pContext, const void** ppData, uint32* pData_size) {
        return crnd_get_data(pContext, ppData, pData_size);
    }

    bool crunch_unpack_level(crnd_unpack_context pContext, void** ppDst, uint32 dst_size_in_bytes, uint32 row_pitch_in_bytes, uint32 level_index) {
        return crnd_unpack_level(pContext, ppDst, dst_size_in_bytes, row_pitch_in_bytes, level_index);
    }

    bool crunch_unpack_level_segmented(crnd_unpack_context pContext, const void* pSrc, uint32 src_size_in_bytes, void** ppDst, uint32 dst_size_in_bytes, uint32 row_pitch_in_bytes, uint32 level_index) {
        return crnd_unpack_level_segmented(pContext, pSrc, src_size_in_bytes, ppDst, dst_size_in_bytes, row_pitch_in_bytes, level_index);
    }

    bool crunch_unpack_end(crnd_unpack_context pContext) {
        return crnd_unpack_end(pContext);
    }

    const void* crunch_get_level_data(const void* pData, uint32 data_size, uint32 level_index, uint32* pSize) {
        return crnd_get_level_data(pData, data_size, level_index, pSize);
    }

    uint32 crunch_get_segmented_file_size(const void* pData, uint32 data_size) {
        return crnd_get_segmented_file_size(pData, data_size);
    }

    bool crunch_create_segmented_file(const void* pData, uint32 data_size, void* pBase_data, uint base_data_size) {
        return crnd_create_segmented_file(pData, data_size, pBase_data, base_data_size);
    }

}
