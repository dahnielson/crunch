#include "../inc/crnlib.h"

extern "C" {

    void crunch_free_block(void *pBlock) {
        crn_free_block(pBlock);
    }

    void *crunch_compress(crn_comp_params *comp_params, crn_uint32 *compressed_size, crn_uint32 *pActual_quality_level = 0, float *pActual_bitrate = 0) {
        return crn_compress(*comp_params, *compressed_size, pActual_quality_level, pActual_bitrate);
    }

    void *crunch_compress_mip(crn_comp_params *comp_params, crn_mipmap_params *mip_params, crn_uint32 *compressed_size, crn_uint32 *pActual_quality_level = 0, float *pActual_bitrate = 0) {
        return crn_compress(*comp_params, *mip_params, *compressed_size, pActual_quality_level, pActual_bitrate);
    }

    void *crunch_decompress_crn_to_dds(void *pCRN_file_data, crn_uint32 *file_size) {
        return crn_decompress_crn_to_dds(pCRN_file_data, *file_size);
    }

    bool crunch_decompress_dss_to_images(void *pDDS_file_data, crn_uint32 dds_file_size, crn_uint32 **ppImages, crn_texture_desc *tex_desc) {
        return crn_decompress_dds_to_images(pDDS_file_data, dds_file_size, ppImages, *tex_desc);
    }

    void crunch_free_all_images(crn_uint32 ** ppImages, crn_texture_desc *desc) {
        return crn_free_all_images(ppImages, *desc);
    }
    
}
