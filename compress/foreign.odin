package crunch_compress

import "core:c"

when ODIN_OS == .Windows {
    foreign import lib {
        "compress.lib",
        "../crnlib/crnlib.lib",
    }
}

// Crunch can compress to these file types.
crn_file_type :: enum c.int32_t {
    // File type .CRN.
    cCRNFileTypeCRN = 0,
    // File type .DDS using regular DXT or clustered DXT.
    cCRNFileTypeDDS,
}

// Supported compressed pixel formats.
// Basically all the standard DX9 formats, with some swizzled DXT5 formats
// (most of them supported by ATI's Compressonator), along with some ATI/X360 GPU specific formats.
crn_format :: enum c.int32_t {
    cCRNFmtInvalid = -1,
    cCRNFmtDXT1 = 0,
    cCRNFmtFirstValid = cCRNFmtDXT1,
    // cCRNFmtDXT3 is not currently supported when writing to CRN - only DDS.
    cCRNFmtDXT3,
    cCRNFmtDXT5,
    // Luma-chroma DXT5 derivative.
    cCRNFmtDXT5_CCxY,
    // Swizzled 2-component DXT5 derivative.
    cCRNFmtDXT5_xGxR,
    // Swizzled 3-component DXT5 derivative.
    cCRNFmtDXT5_xGBR,
    // Swizzled 4-component DXT5 derivative.
    cCRNFmtDXT5_AGBR,
    // ATI 3DC and X360 DXN.
    cCRNFmtDXN_XY,
    // ATI 3DC and X360 DXN.
    cCRNFmtDXN_YX,
    // DXT5 alpha blocks only
    cCRNFmtDXT5A,
    cCRNFmtETC1,
    cCRNFmtTotal,
}

// Various library/file format limits.
crn_limits :: enum c.int {
    // Max mipmap level resolution on any axis.
    cCRNMaxLevelResolution     = 4096,
    cCRNMinPaletteSize         = 8,
    cCRNMaxPaletteSize         = 8192,
    cCRNMaxFaces               = 6,
    cCRNMaxLevels              = 16,
    cCRNMaxHelperThreads       = 16,
    cCRNMinQualityLevel        = 0,
    cCRNMaxQualityLevel        = 255,
}

// CRN/DDS compression flags.
// See the m_flags member in the crn_comp_params struct, below.
crn_comp_flags :: enum c.int32_t {
    // Enables perceptual colorspace distance metrics if set.
    // Important: Be sure to disable this when compressing non-sRGB colorspace images, like normal maps!
    // Default: Set
    cCRNCompFlagPerceptual = 1,

    // Enables (up to) 8x8 macroblock usage if set. If disabled, only 4x4 blocks are allowed.
    // Compression ratio will be lower when disabled, but may cut down on blocky artifacts because the process used to determine
    // where large macroblocks can be used without artifacts isn't perfect.
    // Default: Set.
    cCRNCompFlagHierarchical = 2,

    // cCRNCompFlagQuick disables several output file optimizations - intended for things like quicker previews.
    // Default: Not set.
    cCRNCompFlagQuick = 4,

    // DXT1: OK to use DXT1 alpha blocks for better quality or DXT1A transparency.
    // DXT5: OK to use both DXT5 block types.
    // Currently only used when writing to .DDS files, as .CRN uses only a subset of the possible DXTn block types.
    // Default: Set.
    cCRNCompFlagUseBothBlockTypes = 8,

    // OK to use DXT1A transparent indices to encode black (assumes pixel shader ignores fetched alpha).
    // Currently only used when writing to .DDS files, .CRN never uses alpha blocks.
    // Default: Not set. 
    cCRNCompFlagUseTransparentIndicesForBlack = 16,

    // Disables endpoint caching, for more deterministic output.
    // Currently only used when writing to .DDS files.
    // Default: Not set.
    cCRNCompFlagDisableEndpointCaching = 32,

    // If enabled, use the cCRNColorEndpointPaletteSize, etc. params to control the CRN palette sizes. Only useful when writing to .CRN files.
    // Default: Not set.
    cCRNCompFlagManualPaletteSizes = 64,

    // If enabled, DXT1A alpha blocks are used to encode single bit transparency.
    // Default: Not set.    
    cCRNCompFlagDXT1AForTransparency = 128,

    // If enabled, the DXT1 compressor's color distance metric assumes the pixel shader will be converting the fetched RGB results to luma (Y part of YCbCr).
    // This increases quality when compressing grayscale images, because the compressor can spread the luma error amoung all three channels (i.e. it can generate blocks
    // with some chroma present if doing so will ultimately lead to lower luma error).
    // Only enable on grayscale source images.
    // Default: Not set.
    cCRNCompFlagGrayscaleSampling = 256,
}

// Controls DXTn quality vs. speed control - only used when compressing to .DDS.
crn_dxt_quality :: enum c.int32_t {
    cCRNDXTQualitySuperFast,
    cCRNDXTQualityFast,
    cCRNDXTQualityNormal,
    cCRNDXTQualityBetter,
    cCRNDXTQualityUber,
    cCRNDXTQualityTotal,
}

// Which DXTn compressor to use when compressing to plain (non-clustered) .DDS.
crn_dxt_compressor_type :: enum c.int32_t {
    // Use crunch's ETC1 or DXTc block compressor (default, highest quality, comparable or better than ati_compress or squish, and crnlib's ETC1 is a lot fasterw with similiar quality to Erricson's)
    cCRNDXTCompressorCRN,
    // Use crunch's "fast" DXTc block compressor
    cCRNDXTCompressorCRNF,
    // Use RYG's DXTc block compressor (low quality, but very fast)
    cCRNDXTCompressorRYG,
    cCRNTotalDXTCompressors,
}

crn_progress_callback_func :: proc "c" (phase_index: u32, total_phases: u32, subphase_index: u32, total_subphases: u32, pUser_data_ptr: rawptr)

// CRN/DDS compression parameters struct.
crn_comp_params :: struct {
    m_size_of_obj: u32,
    // Output file type: cCRNFileTypeCRN or cCRNFileTypeDDS.
    m_file_type: crn_file_type,
    // 1 (2D map) or 6 (cubemap)
    m_faces: u32,
    // [1,cCRNMaxLevelResolution], non-power of 2 OK, non-square OK
    m_width: u32,
    // [1,cCRNMaxLevelResolution], non-power of 2 OK, non-square OK
    m_height: u32,
    // [1,cCRNMaxLevelResolution], non-power of 2 OK, non-square OK
    m_levels: u32,
    // Output pixel format.
    m_format: crn_format,
    // See crn_comp_flags enum.
    m_flags: u32,
    // Array of pointers to 32bpp input images.
    m_pImages: [crn_limits.cCRNMaxFaces][crn_limits.cCRNMaxLevels]^u32,
    // Target bitrate - if non-zero, the compressor will use an interpolative search to find the
    // highest quality level that is <= the target bitrate. If it fails to find a bitrate high enough, it'll
    // try disabling adaptive block sizes (cCRNCompFlagHierarchical flag) and redo the search. This process can be pretty slow.
    m_target_bitrate: f32,
    // Desired quality level.
    // Currently, CRN and DDS quality levels are not compatible with eachother from an image quality standpoint.
    m_quality_level: u32,
    // DXTn compression parameter.
    m_dxt1a_alpha_threshold: u32,
    // DXTn compression parameter.
    m_dxt_quality: crn_dxt_quality,
    // DXTn compression parameter.
    m_dxt_compressor_type: crn_dxt_compressor_type,
    // Alpha channel's component. Defaults to 3.
    m_alpha_component: u32,
    // Low-level CRN specific parameter.
    m_crn_adaptive_tile_color_psnr_derating: f32,
    // Low-level CRN specific parameter.
    m_crn_adaptive_tile_alpha_psnr_derating: f32,
    // Low-level CRN specific parameter.
    m_crn_color_endpoint_palette_size: u32,
    // Low-level CRN specific parameter.
    m_crn_color_selector_palette_size: u32,
    // Low-level CRN specific parameter.
    m_crn_alpha_endpoint_palette_size: u32,
    // Low-level CRN specific parameter.
    m_crn_alpha_selector_palette_size: u32,
    // Number of helper threads to create during compression. 0=no threading.
    m_num_helper_threads: u32,
    // CRN userdata0 and userdata1 members, which are written directly to the header of the output file.
    m_userdata0: u32,
    // CRN userdata0 and userdata1 members, which are written directly to the header of the output file.
    m_userdata1: u32,
    // User provided progress callback.
    m_pProgress_func: crn_progress_callback_func,
    m_pProgress_func_data: rawptr,
}

// Mipmap generator's mode.
crn_mip_mode :: enum c.uint32_t {
    // Use source texture's mipmaps if it has any, otherwise generate new mipmaps
    cCRNMipModeUseSourceOrGenerateMips,
    // Use source texture's mipmaps if it has any, otherwise the output has no mipmaps
    cCRNMipModeUseSourceMips,
    // Always generate new mipmaps
    cCRNMipModeGenerateMips,
    // Output texture has no mipmaps
    cCRNMipModeNoMips,
    cCRNMipModeTotal,
}

// Mipmap generator's filter kernel.
crn_mip_filter :: enum c.uint32_t {
    cCRNMipFilterBox,
    cCRNMipFilterTent,
    cCRNMipFilterLanczos4,
    cCRNMipFilterMitchell,
    // Kaiser=default mipmap filter
    cCRNMipFilterKaiser,
    cCRNMipFilterTotal,
}

// Mipmap generator's scale mode.
crn_scale_mode :: enum c.uint32_t {
    cCRNSMDisabled,
    cCRNSMAbsolute,
    cCRNSMRelative,
    cCRNSMLowerPow2,
    cCRNSMNearestPow2,
    cCRNSMNextPow2,
    cCRNSMTotal,
}

// Mipmap generator parameters.
crn_mipmap_params :: struct {
    m_size_of_obj: u32,

    m_mode: crn_mip_mode,
    m_filter: crn_mip_filter,

    m_gamma_filtering: bool,
    m_gamma: f32,

    m_blurriness: f32,

    m_max_levels: u32,
    m_min_mip_size: u32,

    m_renormalize: bool,
    m_tiled: bool,

    m_scale_mode: crn_scale_mode,
    m_scale_x: f32,
    m_scale_y: f32,

    m_window_left: u32,
    m_window_top: u32,
    m_window_right: u32,
    m_window_bottom: u32,

    m_clamp_scale: bool,
    m_clamp_width: u32,
    m_clamp_height: u32,
}

crn_texture_desc :: struct {
   m_faces: u32,
   m_width: u32,
   m_height: u32,
   m_levels: u32,
   m_fmt_fourcc: u32, // Same as crnlib::pixel_format
}

@(default_calling_convention="c", link_prefix="crunch_")
foreign lib {
    // Frees memory blocks allocated by crunch.compress() adn crunch.compress_mip().
    free_block :: proc(pBlock: rawptr) ---

    // Compresses a 32-bit/pixel texture to either: a regular DX9 DDS file, a "clustered" (or reduced entropy) DX9 DDS file, or a CRN file in memory.
    //
    // Notes:
    //  A "regular" DDS file is compressed using normal DXTn compression at the specified DXT quality level.
    //  A "clustered" DDS file is compressed using clustered DXTn compression to either the target bitrate or the specified integer quality factor.
    //  The output file is a standard DX9 format DDS file, except the compressor assumes you will be later losslessly compressing the DDS output file using the LZMA algorithm.
    //  A texture is defined as an array of 1 or 6 "faces" (6 faces=cubemap), where each "face" consists of between [1,cCRNMaxLevels] mipmap levels.
    //  Mipmap levels are simple 32-bit 2D images with a pitch of width*sizeof(uint32), arranged in the usual raster order (top scanline first).
    //  The image pixels may be grayscale (YYYX bytes in memory), grayscale/alpha (YYYA in memory), 24-bit (RGBX in memory), or 32-bit (RGBA) colors (where "X"=don't care).
    //  RGB color data is generally assumed to be in the sRGB colorspace. If not, be sure to clear the "cCRNCompFlagPerceptual" in the crn_comp_params struct!
    compress :: proc(comp_params: ^crn_comp_params, compressed_size: ^u32, actual_quality: ^u32 = nil, actual_bitrate: ^f32 = nil) -> rawptr ---

    // Compresses a 32-bit/pixel texture to either: a regular DX9 DDS file, a "clustered" (or reduced entropy) DX9 DDS file, or a CRN file in memory.
    // This function can also do things like generate mipmaps, and resize or crop the input texture before compression.
    compress_mip :: proc(comp_params: ^crn_comp_params, mip_maps: ^crn_mipmap_params, compressed_size: ^u32, actual_quality: ^u32, actuial_bitrate: ^f32) ---

    // Transcodes an entire CRN file to DDS using the crn_decomp.h header file library to do most of the heavy lifting.
    // The output DDS file's format is guaranteed to be one of the DXTn formats in the crn_format enum.
    // This is a fast operation, because the CRN format is explicitly designed to be efficiently transcodable to DXTn.
    // For more control over decompression, see the lower-level helper functions in crn_decomp.h, which do not depend at all on crnlib.
    crunch_decompress_crn_to_dds :: proc(pCRN_file_data: rawptr, file_size:^u32) -> rawptr ---

    // Decompresses an entire DDS file in any supported format to uncompressed 32-bit/pixel image(s).
    crunch_decompress_dss_to_images :: proc(pDDS_file_data: rawptr, dds_file_size: u32, ppImages: ^^u32, tex_desc: crn_texture_desc) -> bool ---

    // Frees all images allocated by crunch.decompress_dds_to_images().
    crunch_free_all_images :: proc(ppImages: ^^u32, desc: ^crn_texture_desc) ---
}
