package crunch_decompress

import "core:c"

when ODIN_OS == .Windows {
    foreign import lib {
        "decompress.lib",
    }
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

crn_file_info :: struct {
    m_struct_size: u32,
    m_actual_data_size: u32,
    m_header_size: u32,
    m_total_palette_size: u32,
    m_tables_size: u32,
    m_levels: u32,
    m_level_compressed_size: [crn_limits.cCRNMaxLevels]u32,
    m_color_endpoint_palette_entries: u32,
    m_color_selector_palette_entries: u32,
    m_alpha_endpoint_palette_entries: u32,
    m_alpha_selector_palette_entries: u32,
}

crn_texture_info :: struct {
    m_struct_size: u32,
    m_width: u32,
    m_height: u32,
    m_levels: u32,
    m_faces: u32,
    m_bytes_per_block: u32,
    m_userdata0: u32,
    m_userdata1: u32,
    m_format: crn_format,
}

crn_level_info :: struct {
    m_struct_size: u32,
    m_width: u32,
    m_height: u32,
    m_faces: u32,
    m_blocks_x: u32,
    m_blocks_y: u32,
    m_bytes_per_block: u32,
    m_format: crn_format,
}

// Transcode/unpack context handle.
crnd_unpack_context :: rawptr

@(default_calling_convention="c", link_prefix="crunch_")
foreign lib {

    // Returns the FOURCC format code corresponding to the specified CRN format.
    format_to_fourcc :: proc(fmt: crn_format) -> u32 ---

    // Returns the fundamental GPU format given a potentially swizzled DXT5 crn_format.
    get_fundamental_dxt_format :: proc(fmt: crn_format) -> crn_format ---

    // Returns the size of the crn_format in bits/texel (either 4 or 8).
    get_crn_format_bits_per_texel :: proc(fmt: crn_format) -> u32 ---

    // Returns the number of bytes per DXTn block (8 or 16).
    get_bytes_per_dxt_block :: proc(fmt: crn_format) -> u32 ---

    // Validates the entire file by checking the header and data CRC's.
    // This is not something you want to be doing much!
    // The crn_file_info.m_struct_size field must be set before calling this function.
    validate_file :: proc(data: rawptr, data_size: u32, file_info: ^crn_file_info) -> bool ---

    // Retrieves texture information from the CRN file.
    // The crn_texture_info.m_struct_size field must be set before calling this function.
    get_texture_info :: proc(data: rawptr, data_size: u32, texture_info: ^crn_texture_info) -> bool ---

    // Retrieves mipmap level specific information from the CRN file.
    // The crn_level_info.m_struct_size field must be set before calling this function.
    get_level_info :: proc(data: rawptr, data_size: u32, level_index: u32, level_info: ^crn_level_info) -> bool ---

    // Decompresses the texture's decoder tables and endpoint/selector palettes.
    // Once you call this function, you may call crnd_unpack_level() to unpack one or more mip levels.
    // Don't call this once per mip level (unless you absolutely must)!
    // This function allocates enough memory to hold: Huffman decompression tables, and the endpoint/selector palettes (color and/or alpha).
    // Worst case allocation is approx. 200k, assuming all palettes contain 8192 entries.
    // data must point to a buffer holding all of the compressed .CRN file data.
    // This buffer must be stable until crnd_unpack_end() is called.
    // Returns NULL if out of memory, or if any of the input parameters are invalid.
    unpack_begin :: proc(data: rawptr, data_size: u32) -> crnd_unpack_context ---

    // Returns a pointer to the compressed .CRN data associated with a crnd_unpack_context.
    // Returns false if any of the input parameters are invalid.
    get_data :: proc(unpack_context: crnd_unpack_context, data: [^]rawptr) -> bool ---

    // Transcodes the specified mipmap level to a destination buffer in cached or write combined memory.
    // unpack_context - Context created by a call to crnd_unpack_begin().
    // destination - A pointer to an array of 1 or 6 destination buffer pointers. Cubemaps require an array of 6 pointers, 2D textures require an array of 1 pointer.
    // destination_size - Optional size of each destination buffer. Only used for debugging - OK to set to UINT32_MAX.
    // row_pitch - The pitch in bytes from one row of DXT blocks to the next. Must be a multiple of 4.
    // level_index - mipmap level index, where 0 is the largest/first level.
    // Returns false if any of the input parameters, or the compressed stream, are invalid.
    // This function does not allocate any memory.
    unpack_level :: proc(unpack_cotext: crnd_unpack_context, destination: [^]rawptr, destination_size: u32, row_pitch: u32, level_index: u32) -> bool ---

    // Unpacks the specified mipmap level from a "segmented" CRN file.
    // See the crnd_create_segmented_file() API below.
    // Segmented files allow the user to control where the compressed mipmap data is stored.
    unpack_level_segmented :: proc(unpack_context: crnd_unpack_context, source: rawptr, source_size: u32, destination: [^]rawptr, destination_size: u32, row_pitch: u32, level_index: u32) -> bool ---

    // Frees the decompress tables and unpacked palettes associated with the specified unpack context.
    // Returns false if the context is NULL, or if it points to an invalid context.
    // This function frees all memory associated with the context.
    unpack_end :: proc(unpack_context: crnd_unpack_context) -> bool ---

    // Returns a pointer to the level's compressed data, and optionally returns the level's compressed data size if pSize is not NULL.
    get_level_data :: proc(data: rawptr, data_size: u32, level_index: u32, size: u32) -> rawptr ---

    // Returns the compressed size of the texture's header and compression tables (but no levels).
    get_segmented_file_size :: proc(data: rawptr, data_size: u32) -> u32 ---

    // Creates a "segmented" CRN texture from a normal CRN texture. The new texture will be created at pBase_data, and will be crnd_get_base_data_size() bytes long.
    // base_data_size must be >= crnd_get_base_data_size().
    // The base data will contain the CRN header and compression tables, but no mipmap data.
    create_segmented_file :: proc(data: rawptr, data_size: u32, base_data: rawptr, base_data_size: u32) -> bool ---

}
