{This unit is part of United Openlibraries of Sound (uos)}

{This is the Pascal Wrapper + Dynamic loading of fdk_aacdecoder library.
 Load library with ad_load() and release with ad_unload().
 License : modified LGPL. 
 Fred van Stappen / fiens@hotmail.com / 2024}

unit uos_fdkaacdecoder;

{$mode objfpc}{$H+}
{$PACKRECORDS C}
{$MINENUMSIZE 4}

interface

uses
  dynlibs,
  SysUtils;

type
  FDK_MODULE_ID = (
    FDK_NONE    = 0,
    FDK_TOOLS  = 1,
    FDK_SYSLIB = 2,
    FDK_AACDEC = 3,
    FDK_AACENC = 4,
    FDK_SBRDEC = 5,
    FDK_SBRENC = 6,
    FDK_TPDEC = 7,
    FDK_TPENC = 8,
    FDK_MPSDEC       = 9,
    FDK_MPEGFILEREAD = 10,
    FDK_MPEGFILEWRITE = 11,
    FDK_PCMDMX        = 31,
    FDK_MPSENC  = 34,
    FDK_TDLIMIT = 35,
    FDK_UNIDRCDEC = 38,

    FDK_MODULE_LAST
    );

type
(**
   *  Library information.
   *)
  PPLIB_INFO = ^PLIB_INFO;
  PLIB_INFO  = ^LIB_INFO;

  LIB_INFO = record
    title: MarshaledAString;
    build_date: MarshaledAString;
    build_time: MarshaledAString;
    module_id: FDK_MODULE_ID;
    version: integer;
    flags: cardinal;
    versionStr: array[0..31] of AnsiChar;
  end;

const
  _PU = '';
  {$IF Defined(MSWINDOWS)}
    {$IFDEF CPUX64}
      libfdk_aac = 'libfdk-aac-2.dll';
    {$ENDIF}
    {$IFDEF CPUX86}
      libfdk_aac = 'libfdk-aac-2.dll';
    {$ENDIF}
  {$ELSEIF Defined(DARWIN) or Defined(MACOS)}
    libfdk_aac = '@executable_path/../Frameworks/libfdk-aac-2.dylib';
    _PU = '_'
  {$ELSEIF Defined(UNIX)}
    libfdk_aac = 'libfdk-aac-2.so';
  {$IFEND}

type
  (**
   * File format identifiers.
   *)
  FILE_FORMAT  = (
    FF_UNKNOWN = -1,  (**< Unknown format.        *)
    FF_RAW = 0,       (**< No container, bit stream data conveyed "as is". *)

    FF_MP4_3GPP = 3,  (**< 3GPP file format.      *)
    FF_MP4_MP4F = 4,  (**< MPEG-4 File format.     *)

    FF_RAWPACKETS = 5 (**< Proprietary raw packet file. *)
    );

  (**
   * Transport type identifiers.
   *)
  TRANSPORT_TYPE = (
    TT_UNKNOWN   = -1, (**< Unknown format.            *)
    TT_MP4_RAW = 0,  (**< "as is" access units (packet based since there is
                        obviously no sync layer) *)
    TT_MP4_ADIF = 1, (**< ADIF bitstream format.     *)
    TT_MP4_ADTS = 2, (**< ADTS bitstream format.     *)

    TT_MP4_LATM_MCP1 = 6, (**< Audio Mux Elements with muxConfigPresent = 1 *)
    TT_MP4_LATM_MCP0 = 7, (**< Audio Mux Elements with muxConfigPresent = 0, out
                             of band StreamMuxConfig *)

    TT_MP4_LOAS = 10, (**< Audio Sync Stream.         *)

    TT_DRM = 12 (**< Digital Radio Mondial (DRM30/DRM+) bitstream format. *)
    );

 //TT_IS_PACKET(x)                                                   \
 //  (((x) == TT_MP4_RAW) || ((x) == TT_DRM) || ((x) == TT_MP4_LATM_MCP0) || \
 //   ((x) == TT_MP4_LATM_MCP1))
function TT_IS_PACKET(x: TRANSPORT_TYPE): Boolean;

type
  (**
   * Audio Object Type definitions.
   *)
  AUDIO_OBJECT_TYPE = (
    AOT_NONE        = -1,
    AOT_NULL_OBJECT = 0,
    AOT_AAC_MAIN    = 1, (**< Main profile                              *)
    AOT_AAC_LC = 2,      (**< Low Complexity object                     *)
    AOT_AAC_SSR = 3,
    AOT_AAC_LTP = 4,
    AOT_SBR      = 5,
    AOT_AAC_SCAL = 6,
    AOT_TWIN_VQ = 7,
    AOT_CELP    = 8,
    AOT_HVXC    = 9,
    AOT_RSVD_10 = 10,          (**< (reserved)                                *)
    AOT_RSVD_11 = 11,          (**< (reserved)                                *)
    AOT_TTSI = 12,             (**< TTSI Object                               *)
    AOT_MAIN_SYNTH = 13,       (**< Main Synthetic object                     *)
    AOT_WAV_TAB_SYNTH = 14,    (**< Wavetable Synthesis object                *)
    AOT_GEN_MIDI = 15,         (**< General MIDI object                       *)
    AOT_ALG_SYNTH_AUD_FX = 16, (**< Algorithmic Synthesis and Audio FX object *)
    AOT_ER_AAC_LC = 17,        (**< Error Resilient(ER) AAC Low Complexity    *)
    AOT_RSVD_18 = 18,          (**< (reserved)                                *)
    AOT_ER_AAC_LTP = 19,       (**< Error Resilient(ER) AAC LTP object        *)
    AOT_ER_AAC_SCAL = 20,      (**< Error Resilient(ER) AAC Scalable object   *)
    AOT_ER_TWIN_VQ = 21,       (**< Error Resilient(ER) TwinVQ object         *)
    AOT_ER_BSAC = 22,          (**< Error Resilient(ER) BSAC object           *)
    AOT_ER_AAC_LD = 23,        (**< Error Resilient(ER) AAC LowDelay object   *)
    AOT_ER_CELP = 24,          (**< Error Resilient(ER) CELP object           *)
    AOT_ER_HVXC = 25,          (**< Error Resilient(ER) HVXC object           *)
    AOT_ER_HILN = 26,          (**< Error Resilient(ER) HILN object           *)
    AOT_ER_PARA = 27,          (**< Error Resilient(ER) Parametric object     *)
    AOT_RSVD_28 = 28,          (**< might become SSC                          *)
    AOT_PS = 29,               (**< PS, Parametric Stereo (includes SBR)      *)
    AOT_MPEGS = 30,            (**< MPEG Surround                             *)

    AOT_ESCAPE = 31, (**< Signal AOT uses more than 5 bits          *)

    AOT_MP3ONMP4_L1 = 32, (**< MPEG-Layer1 in mp4                        *)
    AOT_MP3ONMP4_L2 = 33, (**< MPEG-Layer2 in mp4                        *)
    AOT_MP3ONMP4_L3 = 34, (**< MPEG-Layer3 in mp4                        *)
    AOT_RSVD_35 = 35,     (**< might become DST                          *)
    AOT_RSVD_36 = 36,     (**< might become ALS                          *)
    AOT_AAC_SLS = 37,     (**< AAC + SLS                                 *)
    AOT_SLS = 38,         (**< SLS                                       *)
    AOT_ER_AAC_ELD = 39,  (**< AAC Enhanced Low Delay                    *)

    AOT_USAC = 42,     (**< USAC                                      *)
    AOT_SAOC = 43,     (**< SAOC                                      *)
    AOT_LD_MPEGS = 44, (**< Low Delay MPEG Surround                   *)

         (* Pseudo AOTs *)
    AOT_MP2_AAC_LC = 129, (**< Virtual AOT MP2 Low Complexity profile *)
    AOT_MP2_SBR = 132, (**< Virtual AOT MP2 Low Complexity Profile with SBR    *)

    AOT_DRM_AAC = 143, (**< Virtual AOT for DRM (ER-AAC-SCAL without SBR) *)
    AOT_DRM_SBR = 144, (**< Virtual AOT for DRM (ER-AAC-SCAL with SBR) *)
    AOT_DRM_MPEG_PS =
    145, (**< Virtual AOT for DRM (ER-AAC-SCAL with SBR and MPEG-PS) *)
    AOT_DRM_SURROUND =
    146, (**< Virtual AOT for DRM Surround (ER-AAC-SCAL (+SBR) +MPS) *)
    AOT_DRM_USAC = 147 (**< Virtual AOT for DRM with USAC *)
    );

         //CAN_DO_PS(aot)                                           \
         //  ((aot) == AOT_AAC_LC || (aot) == AOT_SBR || (aot) == AOT_PS || \
         //   (aot) == AOT_ER_BSAC || (aot) == AOT_DRM_AAC)
function CAN_DO_PS(aot: AUDIO_OBJECT_TYPE): Boolean;

         //IS_USAC(aot) ((aot) == AOT_USAC)
function IS_USAC(aot: AUDIO_OBJECT_TYPE): Boolean;

         //IS_LOWDELAY(aot) ((aot) == AOT_ER_AAC_LD || (aot) == AOT_ER_AAC_ELD)
function IS_LOWDELAY(aot: AUDIO_OBJECT_TYPE): Boolean;

type
  (** Channel Mode ( 1-7 equals MPEG channel configurations, others are
   * arbitrary). *)
  CHANNEL_MODE   = (
    MODE_INVALID = -1,
    MODE_UNKNOWN = 0,
    MODE_1       = 1,         (**< C *)
    MODE_2 = 2,         (**< L+R *)
    MODE_1_2 = 3,       (**< C, L+R *)
    MODE_1_2_1 = 4,     (**< C, L+R, Rear *)
    MODE_1_2_2 = 5,     (**< C, L+R, LS+RS *)
    MODE_1_2_2_1 = 6,   (**< C, L+R, LS+RS, LFE *)
    MODE_1_2_2_2_1 = 7, (**< C, LC+RC, L+R, LS+RS, LFE *)

    MODE_6_1 = 11,           (**< C, L+R, LS+RS, Crear, LFE *)
    MODE_7_1_BACK = 12,      (**< C, L+R, LS+RS, Lrear+Rrear, LFE *)
    MODE_7_1_TOP_FRONT = 14, (**< C, L+R, LS+RS, LFE, Ltop+Rtop *)

    MODE_7_1_REAR_SURROUND = 33, (**< C, L+R, LS+RS, Lrear+Rrear, LFE *)
    MODE_7_1_FRONT_CENTER = 34,  (**< C, LC+RC, L+R, LS+RS, LFE *)

    MODE_212 = 128 (**< 212 configuration, used in ELDv2 *)
    );

  (**
   * Speaker description tags.
   * Do not change the enumeration values unless it keeps the following
   * segmentation:
   * - Bit 0-3: Horizontal postion (0: none, 1: front, 2: side, 3: back, 4: lfe)
   * - Bit 4-7: Vertical position (0: normal, 1: top, 2: bottom)
   *)
  AUDIO_CHANNEL_TYPE = (
    ACT_NONE         = $00,
    ACT_FRONT = $01,        (*!< Front speaker position (at normal height) *)
    ACT_SIDE = $02,         (*!< Side speaker position (at normal height) *)
    ACT_BACK = $03,         (*!< Back speaker position (at normal height) *)
    ACT_LFE = $04,          (*!< Low frequency effect speaker postion (front) *)

    ACT_TOP = $10,          (*!< Top speaker area (for combination with speaker positions) *)
    ACT_FRONT_TOP = $11,    (*!< Top front speaker = (ACT_FRONT|ACT_TOP) *)
    ACT_SIDE_TOP = $12,     (*!< Top side speaker  = (ACT_SIDE |ACT_TOP) *)
    ACT_BACK_TOP = $13,     (*!< Top back speaker  = (ACT_BACK |ACT_TOP) *)

    ACT_BOTTOM = $20,       (*!< Bottom speaker area (for combination with speaker positions) *)
    ACT_FRONT_BOTTOM = $21, (*!< Bottom front speaker = (ACT_FRONT|ACT_BOTTOM) *)
    ACT_SIDE_BOTTOM = $22,  (*!< Bottom side speaker  = (ACT_SIDE |ACT_BOTTOM) *)
    ACT_BACK_BOTTOM = $23   (*!< Bottom back speaker  = (ACT_BACK |ACT_BOTTOM) *)
    );

  SBR_PS_SIGNALING = (
    SIG_UNKNOWN    = -1,
    SIG_IMPLICIT = 0,
    SIG_EXPLICIT_BW_COMPATIBLE = 1,
    SIG_EXPLICIT_HIERARCHICAL = 2
    );

const
  (**
   * Audio Codec flags.
   *)
  AC_ER_VCB11     = $000001; (*!< aacSectionDataResilienceFlag     flag (from ASC): 1 means use
                virtual codebooks  *)
  AC_ER_RVLC      = $000002; (*!< aacSpectralDataResilienceFlag     flag (from ASC): 1 means use
                huffman codeword reordering *)
  AC_ER_HCR       = $000004; (*!< aacSectionDataResilienceFlag     flag (from ASC): 1 means use
                virtual codebooks  *)
  AC_SCALABLE     = $000008;          (*!< AAC Scalable*)
  AC_ELD          = $000010;          (*!< AAC-ELD *)
  AC_LD           = $000020;          (*!< AAC-LD *)
  AC_ER           = $000040;          (*!< ER syntax *)
  AC_BSAC         = $000080;          (*!< BSAC *)
  AC_USAC         = $000100;          (*!< USAC *)
  AC_RSV603DA     = $000200;          (*!< RSVD60 3D audio *)
  AC_HDAAC        = $000400;          (*!< HD-AAC *)
  AC_RSVD50       = $004000;          (*!< Rsvd50 *)
  AC_SBR_PRESENT  = $008000;          (*!< SBR present flag (from ASC) *)
  AC_SBRCRC       = $010000;          (*!< SBR CRC present flag. Only relevant for AAC-ELD for now. *)
  AC_PS_PRESENT   = $020000;          (*!< PS present flag (from ASC or implicit)  *)
  AC_MPS_PRESENT  = $040000;                    (*!< MPS present flag (from ASC or implicit)
                                 *)
  AC_DRM          = $080000;          (*!< DRM bit stream syntax *)
  AC_INDEP        = $100000;          (*!< Independency flag *)
  AC_MPEGD_RES    = $200000;          (*!< MPEG-D residual individual channel data. *)
  AC_SAOC_PRESENT = $400000;          (*!< SAOC Present Flag *)
  AC_DAB          = $800000;            (*!< DAB bit stream syntax *)
  AC_ELD_DOWNSCALE = $1000000;        (*!< ELD Downscaled playout *)
  AC_LD_MPS       = $2000000;         (*!< Low Delay MPS. *)
  AC_DRC_PRESENT  = $4000000; (*!< Dynamic Range Control (DRC) data found.
               *)
  AC_USAC_SCFGI3  = $8000000;         (*!< USAC flag: If stereoConfigIndex is 3 the flag is set. *)
  (**
   * Audio Codec flags (reconfiguration).
   *)
  AC_CM_DET_CFG_CHANGE = $000001; (*!< Config mode signalizes the callback to work in config change
                detection mode *)
  AC_CM_ALLOC_MEM = $000002; (*!< Config mode signalizes the callback to work in memory
                allocation mode *)

  (**
   * Audio Codec flags (element specific).
   *)
  AC_EL_USAC_TW   = $000001;    (*!< USAC time warped filter bank is active *)
  AC_EL_USAC_NOISE = $000002; (*!< USAC noise filling is active *)
  AC_EL_USAC_ITES = $000004;  (*!< USAC SBR inter-TES tool is active *)
  AC_EL_USAC_PVC  = $000008; (*!< USAC SBR predictive vector coding tool is active *)
  AC_EL_USAC_MPS212 = $000010; (*!< USAC MPS212 tool is active *)
  AC_EL_USAC_LFE  = $000020;    (*!< USAC element is LFE *)
  AC_EL_USAC_CP_POSSIBLE = $000040; (*!< USAC may use Complex Stereo Prediction in this channel element
              *)
  AC_EL_ENHANCED_NOISE = $000080;   (*!< Enhanced noise filling*)
  AC_EL_IGF_AFTER_TNS = $000100;    (*!< IGF after TNS *)
  AC_EL_IGF_INDEP_TILING = $000200; (*!< IGF independent tiling *)
  AC_EL_IGF_USE_ENF = $000400;      (*!< IGF use enhanced noise filling *)
  AC_EL_FULLBANDLPD = $000800;      (*!< enable fullband LPD tools *)
  AC_EL_LPDSTEREOIDX = $001000;     (*!< LPD-stereo-tool stereo index *)
  AC_EL_LFE       = $002000;              (*!< The element is of type LFE. *)

  (* CODER_CONFIG::flags *)
  CC_MPEG_ID      = $00100000;
  CC_IS_BASELAYER = $00200000;
  CC_PROTECTION   = $00400000;
  CC_SBR          = $00800000;
  CC_SBRCRC       = $00010000;
  CC_SAC          = $00020000;
  CC_RVLC         = $01000000;
  CC_VCB11        = $02000000;
  CC_HCR          = $04000000;
  CC_PSEUDO_SURROUND = $08000000;
  CC_USAC_NOISE   = $10000000;
  CC_USAC_TW      = $20000000;
  CC_USAC_HBE     = $40000000;

type
  (** Generic audio coder configuration structure. *)
  TCODER_CONFIG = record
    aot: AUDIO_OBJECT_TYPE;     (**< Audio Object Type (AOT).           *)
    extAOT: AUDIO_OBJECT_TYPE;  (**< Extension Audio Object Type (SBR). *)
    channelMode: CHANNEL_MODE;  (**< Channel mode.                      *)
    channelConfigZero: byte;   (**< Use channel config zero + pce although a
                                  standard channel config could be signaled. *)
    samplingRate: integer;          (**< Sampling rate.                     *)
    extSamplingRate: integer;       (**< Extended samplerate (SBR).         *)
    downscaleSamplingRate: integer; (**< Downscale sampling rate (ELD downscaled mode)
                                *)
    bitRate: integer;               (**< Average bitrate.                   *)
    samplesPerFrame: integer; (**< Number of PCM samples per codec frame and audio
                            channel. *)
    noChannels: integer;      (**< Number of audio channels.          *)
    bitsFrame: integer;
    nSubFrames: integer; (**< Amount of encoder subframes. 1 means no subframing. *)
    BSACnumOfSubFrame: integer; (**< The number of the sub-frames which are grouped and
                              transmitted in a super-frame (BSAC). *)
    BSAClayerLength: integer; (**< The average length of the large-step layers in bytes
                            (BSAC).                            *)
    flags: cardinal;          (**< flags *)
    matrixMixdownA: byte; (**< Matrix mixdown index to put into PCE. Default value
                             0 means no mixdown coefficient, valid values are 1-4
                             which correspond to matrix_mixdown_idx 0-3. *)
    headerPeriod: byte;   (**< Frame period for sending in band configuration
                             buffers in the transport layer. *)

    stereoConfigIndex: byte;         (**< USAC MPS stereo mode *)
    sbrMode: byte;                   (**< USAC SBR mode *)
    sbrSignaling: SBR_PS_SIGNALING; (**< 0: implicit signaling, 1: backwards
                                      compatible explicit signaling, 2:
                                      hierarcical explicit signaling *)

    rawConfig: array[0..63] of byte; (**< raw codec specific config as bit stream *)
    rawConfigBits: integer;          (**< Size of rawConfig in bits *)

    sbrPresent: byte;
    psPresent: byte;
  end;

const
  USAC_ID_BIT = 16; (** USAC element IDs start at USAC_ID_BIT *)

type
    (** MP4 Element IDs. *)
  MP4_ELEMENT_ID = (
    (* mp4 element IDs *)
    ID_NONE      = -1, (**< Invalid Element helper ID.             *)
    ID_SCE = 0,   (**< Single Channel Element.                *)
    ID_CPE = 1,   (**< Channel Pair Element.                  *)
    ID_CCE = 2,   (**< Coupling Channel Element.              *)
    ID_LFE = 3,   (**< LFE Channel Element.                   *)
    ID_DSE = 4,   (**< Currently one Data Stream Element for ancillary data is
                     supported. *)
    ID_PCE = 5,   (**< Program Config Element.                *)
    ID_FIL = 6,   (**< Fill Element.                          *)
    ID_END = 7,   (**< Arnie (End Element = Terminator).      *)
    ID_EXT = 8,   (**< Extension Payload (ER only).           *)
    ID_SCAL = 9,  (**< AAC scalable element (ER only).        *)
    (* USAC element IDs *)
    ID_USAC_SCE = 0 + USAC_ID_BIT, (**< Single Channel Element.                *)
    ID_USAC_CPE = 1 + USAC_ID_BIT, (**< Channel Pair Element.                  *)
    ID_USAC_LFE = 2 + USAC_ID_BIT, (**< LFE Channel Element.                   *)
    ID_USAC_EXT = 3 + USAC_ID_BIT, (**< Extension Element.                     *)
    ID_USAC_END = 4 + USAC_ID_BIT, (**< Arnie (End Element = Terminator).      *)
    ID_LAST
    );

  (* usacConfigExtType q.v. ISO/IEC DIS 23008-3 Table 52  and  ISO/IEC FDIS
   * 23003-3:2011(E) Table 74*)
  CONFIG_EXT_ID        = (
    (* USAC and RSVD60 3DA *)
    ID_CONFIG_EXT_FILL = 0,
    (* RSVD60 3DA *)
    ID_CONFIG_EXT_DOWNMIX       = 1,
    ID_CONFIG_EXT_LOUDNESS_INFO = 2,
    ID_CONFIG_EXT_AUDIOSCENE_INFO = 3,
    ID_CONFIG_EXT_HOA_MATRIX      = 4,
    ID_CONFIG_EXT_SIG_GROUP_INFO = 6
    (* 5-127 => reserved for ISO use *)
    (* > 128 => reserved for use outside of ISO scope *)
    );

    //IS_CHANNEL_ELEMENT(elementId)                                         \
    //  ((elementId) == ID_SCE || (elementId) == ID_CPE || (elementId) == ID_LFE || \
    //   (elementId) == ID_USAC_SCE || (elementId) == ID_USAC_CPE ||                \
    //   (elementId) == ID_USAC_LFE)
function IS_CHANNEL_ELEMENT(elementId: MP4_ELEMENT_ID): Boolean;

    //IS_MP4_CHANNEL_ELEMENT(elementId) \
    //  ((elementId) == ID_SCE || (elementId) == ID_CPE || (elementId) == ID_LFE)
function IS_MP4_CHANNEL_ELEMENT(elementId: MP4_ELEMENT_ID): Boolean;

const
  EXT_ID_BITS = 4; (**< Size in bits of extension payload type tags. *)

type
  (** Extension payload types. *)
  EXT_PAYLOAD_TYPE = (
    EXT_FIL        = $00,
    EXT_FILL_DATA    = $01,
    EXT_DATA_ELEMENT = $02,
    EXT_DATA_LENGTH = $03,
    EXT_UNI_DRC     = $04,
    EXT_LDSAC_DATA = $09,
    EXT_SAOC_DATA  = $0a,
    EXT_DYNAMIC_RANGE = $0b,
    EXT_SAC_DATA      = $0c,
    EXT_SBR_DATA     = $0d,
    EXT_SBR_DATA_CRC = $0e
    );

 //IS_USAC_CHANNEL_ELEMENT(elementId)                     \
 //  ((elementId) == ID_USAC_SCE || (elementId) == ID_USAC_CPE || \
 //   (elementId) == ID_USAC_LFE)
function IS_USAC_CHANNEL_ELEMENT(elementId: MP4_ELEMENT_ID): Boolean;

type
    (** MPEG-D USAC & RSVD60 3D audio Extension Element Types. *)
  USAC_EXT_ELEMENT_TYPE = (
    (* usac *)
    ID_EXT_ELE_FILL     = $00,
    ID_EXT_ELE_MPEGS = $01,
    ID_EXT_ELE_SAOC  = $02,
    ID_EXT_ELE_AUDIOPREROLL = $03,
    ID_EXT_ELE_UNI_DRC      = $04,
    (* rsv603da *)
    ID_EXT_ELE_OBJ_METADATA = $05,
    ID_EXT_ELE_SAOC_3D      = $06,
    ID_EXT_ELE_HOA        = $07,
    ID_EXT_ELE_FMT_CNVRTR = $08,
    ID_EXT_ELE_MCT = $09,
    ID_EXT_ELE_ENHANCED_OBJ_METADATA = $0d,
    (* reserved for use outside of ISO scope *)
    ID_EXT_ELE_VR_METADATA = $81,
    ID_EXT_ELE_UNKNOWN     = $FF
    );

  (**
   * Proprietary raw packet file configuration data type identifier.
   *)
  TP_CONFIG_TYPE = (
    TC_NOTHING   = 0,     (* No configuration available -> in-band configuration.   *)
    TC_RAW_ADTS = 2,      (* Transfer type is ADTS. *)
    TC_RAW_LATM_MCP1 = 6, (* Transfer type is LATM with SMC present.    *)
    TC_RAW_SDC = 21       (* Configuration data field is Drm SDC.             *)

    );

const
  (* AAC capability flags *)
  CAPF_AAC_LC       = $00000001; (**< Support flag for AAC Low Complexity. *)
  CAPF_ER_AAC_LD    = $00000002; (**< Support flag for AAC Low Delay with Error Resilience tools.
                *)
  CAPF_ER_AAC_SCAL  = $00000004; (**< Support flag for AAC Scalable. *)
  CAPF_ER_AAC_LC    = $00000008; (**< Support flag for AAC Low Complexity with Error Resilience
                  tools. *)
  CAPF_AAC_480      = $00000010; (**< Support flag for AAC with 480 framelength.  *)
  CAPF_AAC_512      = $00000020; (**< Support flag for AAC with 512 framelength.  *)
  CAPF_AAC_960      = $00000040; (**< Support flag for AAC with 960 framelength.  *)
  CAPF_AAC_1024     = $00000080; (**< Support flag for AAC with 1024 framelength. *)
  CAPF_AAC_HCR      = $00000100; (**< Support flag for AAC with Huffman Codeword Reordering.    *)
  CAPF_AAC_VCB11    = $00000200; (**< Support flag for AAC Virtual Codebook 11.    *)
  CAPF_AAC_RVLC     = $00000400; (**< Support flag for AAC Reversible Variable Length Coding.   *)
  CAPF_AAC_MPEG4    = $00000800; (**< Support flag for MPEG file format. *)
  CAPF_AAC_DRC      = $00001000; (**< Support flag for AAC Dynamic Range Control. *)
  CAPF_AAC_CONCEALMENT = $00002000; (**< Support flag for AAC concealment.           *)
  CAPF_AAC_DRM_BSFORMAT = $00004000; (**< Support flag for AAC DRM bistream format. *)
  CAPF_ER_AAC_ELD   = $00008000; (**< Support flag for AAC Enhanced Low Delay with Error
                  Resilience tools.  *)
  CAPF_ER_AAC_BSAC  = $00010000; (**< Support flag for AAC BSAC.                           *)
  CAPF_AAC_ELD_DOWNSCALE = $00040000; (**< Support flag for AAC-ELD Downscaling           *)
  CAPF_AAC_USAC_LP  = $00100000; (**< Support flag for USAC low power mode. *)
  CAPF_AAC_USAC     = $00200000; (**< Support flag for Unified Speech and Audio Coding (USAC). *)
  CAPF_ER_AAC_ELDV2 = $00800000; (**< Support flag for AAC Enhanced Low Delay with MPS 212.  *)
  CAPF_AAC_UNIDRC   = $01000000; (**< Support flag for MPEG-D Dynamic Range Control (uniDrc). *)

  (* Transport capability flags *)
  CAPF_ADTS         = $00000001; (**< Support flag for ADTS transport format.        *)
  CAPF_ADIF         = $00000002; (**< Support flag for ADIF transport format.        *)
  CAPF_LATM         = $00000004; (**< Support flag for LATM transport format.        *)
  CAPF_LOAS         = $00000008; (**< Support flag for LOAS transport format.        *)
  CAPF_RAWPACKETS   = $00000010; (**< Support flag for RAW PACKETS transport format. *)
  CAPF_DRM          = $00000020; (**< Support flag for DRM/DRM+ transport format.    *)
  CAPF_RSVD50       = $00000040; (**< Support flag for RSVD50 transport format       *)

  (* SBR capability flags *)
  CAPF_SBR_LP       = $00000001; (**< Support flag for SBR Low Power mode.           *)
  CAPF_SBR_HQ       = $00000002; (**< Support flag for SBR High Quality mode.        *)
  CAPF_SBR_DRM_BS   = $00000004; (**< Support flag for                               *)
  CAPF_SBR_CONCEALMENT = $00000008; (**< Support flag for SBR concealment.              *)
  CAPF_SBR_DRC      = $00000010; (**< Support flag for SBR Dynamic Range Control.    *)
  CAPF_SBR_PS_MPEG  = $00000020; (**< Support flag for MPEG Parametric Stereo.       *)
  CAPF_SBR_PS_DRM   = $00000040; (**< Support flag for DRM Parametric Stereo.        *)
  CAPF_SBR_ELD_DOWNSCALE = $00000080; (**< Support flag for ELD reduced delay mode        *)
  CAPF_SBR_HBEHQ    = $00000100; (**< Support flag for HQ HBE                        *)

  (* PCM utils capability flags *)
  CAPF_DMX_BLIND    = $00000001; (**< Support flag for blind downmixing.             *)
  CAPF_DMX_PCE      = $00000002; (**< Support flag for guided downmix with data from MPEG-2/4
                  Program Config Elements (PCE). *)
  CAPF_DMX_ARIB     = $00000004; (**< Support flag for PCE guided downmix with slightly different
                  equations and levels to fulfill ARIB standard. *)
  CAPF_DMX_DVB      = $00000008; (**< Support flag for guided downmix with data from DVB ancillary
                  data fields. *)
  CAPF_DMX_CH_EXP   = $00000010; (**< Support flag for simple upmixing by dublicating channels or
                  adding zero channels. *)
  CAPF_DMX_6_CH     = $00000020; (**< Support flag for 5.1 channel configuration (input and
                  output). *)
  CAPF_DMX_8_CH     = $00000040; (**< Support flag for 6 and 7.1 channel configurations (input and
                  output). *)
  CAPF_DMX_24_CH    = $00000080; (**< Support flag for 22.2 channel configuration (input and
                  output). *)
  CAPF_LIMITER      = $00002000; (**< Support flag for signal level limiting.
                *)

  (* MPEG Surround capability flags *)
  CAPF_MPS_STD      = $00000001; (**< Support flag for MPEG Surround.           *)
  CAPF_MPS_LD       = $00000002; (**< Support flag for Low Delay MPEG Surround.
                *)
  CAPF_MPS_USAC     = $00000004; (**< Support flag for USAC MPEG Surround.      *)
  CAPF_MPS_HQ       = $00000010; (**< Support flag indicating if high quality processing is
                  supported *)
  CAPF_MPS_LP       = $00000020; (**< Support flag indicating if partially complex (low power)
                  processing is supported *)
  CAPF_MPS_BLIND    = $00000040; (**< Support flag indicating if blind processing is supported *)
  CAPF_MPS_BINAURAL = $00000080; (**< Support flag indicating if binaural output is possible *)
  CAPF_MPS_2CH_OUT  = $00000100; (**< Support flag indicating if 2ch output is possible      *)
  CAPF_MPS_6CH_OUT  = $00000200; (**< Support flag indicating if 6ch output is possible      *)
  CAPF_MPS_8CH_OUT  = $00000400; (**< Support flag indicating if 8ch output is possible      *)
  CAPF_MPS_1CH_IN   = $00001000; (**< Support flag indicating if 1ch dmx input is possible   *)
  CAPF_MPS_2CH_IN   = $00002000; (**< Support flag indicating if 2ch dmx input is possible   *)
  CAPF_MPS_6CH_IN   = $00004000; (**< Support flag indicating if 5ch dmx input is possible   *)

  (* \endcond *)


  (*
   * ##############################################################################################
   * Library versioning
   * ##############################################################################################
   *)

    (**
   * Convert each member of version numbers to one single numeric version
   * representation.
   * \param lev0  1st level of version number.
   * \param lev1  2nd level of version number.
   * \param lev2  3rd level of version number.
   *)
 //LIB_VERSION(lev0, lev1, lev2)                      \
 //  ((lev0 << 24 & = $ff000000) | (lev1 << 16 & = $00ff0000) | \
 //   (lev2 << 8 & = $0000ff00))

function LIB_VERSION(lev0: byte; lev1: byte; lev2: byte): integer;

  (**
   *  Build text string of version.
   *)
 //LIB_VERSION_STRING(info)                                               \
 //  FDKsprintf((info)->versionStr, "%d.%d.%d", (((info)->version >> 24) & = $ff), \
 //             (((info)->version >> 16) & = $ff),                                 \
 //             (((info)->version >> 8) & = $ff))
function LIB_VERSION_STRING(info: LIB_INFO): string;


 (** Initialize library info. *)
 //static FDK_AUDIO_INLINE void FDKinitLibInfo(LIB_INFO* info) {
 //  int i;

 //  for (i = 0; i < FDK_MODULE_LAST; i++) {
 //    info[i].module_id = FDK_NONE;
 //  }
 //}
procedure FDKinitLibInfo(var info: array of LIB_INFO);


 (** Aquire supported features of library. *)
 //static FDK_AUDIO_INLINE UINT
 //FDKlibInfo_getCapabilities(const LIB_INFO* info, FDK_MODULE_ID module_id) {
 //  int i;

 //  for (i = 0; i < FDK_MODULE_LAST; i++) {
 //    if (info[i].module_id == module_id) {
 //      return info[i].flags;
 //    }
 //  }
 //  return 0;
 //}
function FDKlibInfo_getCapabilities(const info: array of LIB_INFO; module_id: FDK_MODULE_ID): cardinal;


 (** Search for next free tab. *)
 //static FDK_AUDIO_INLINE INT FDKlibInfo_lookup(const LIB_INFO* info,
 //                                              FDK_MODULE_ID module_id) {
 //  int i = -1;

 //  for (i = 0; i < FDK_MODULE_LAST; i++) {
 //    if (info[i].module_id == module_id) return -1;
 //    if (info[i].module_id == FDK_NONE) break;
 //  }
 //  if (i == FDK_MODULE_LAST) return -1;

 //  return i;
 //}
function FDKlibInfo_lookup(const info: array of LIB_INFO; module_id: FDK_MODULE_ID): integer;

type
  (*
   * ##############################################################################################
   * Buffer description
   * ##############################################################################################
   *)

  (**
   *  I/O buffer descriptor.
   *)
  FDK_bufDescr = record
    ppBase: Pointer;  (*!< Pointer to an array containing buffer base addresses.
                         Set to NULL for buffer requirement info. *)
    pBufSize: PCardinal; (*!< Pointer to an array containing the number of elements
                       that can be placed in the specific buffer. *)
    pEleSize: PCardinal; (*!< Pointer to an array containing the element size for each
                       buffer in bytes. That is mostly the number returned by the
                       sizeof() operator for the data type used for the specific
                       buffer. *)
    pBufType: PCardinal; (*!< Pointer to an array of bit fields containing a description
                       for each buffer. See XXX below for more details.  *)
    numBufs: cardinal; (*!< Total number of buffers. *)
  end;

(**
 * Buffer type description field.
 *)
const
  FDK_BUF_TYPE_MASK_IO    = (cardinal($03) shl 30);
  FDK_BUF_TYPE_MASK_DESCR = (cardinal($3F) shl 16);
  FDK_BUF_TYPE_MASK_ID    = cardinal($FF);

  FDK_BUF_TYPE_INPUT      = (cardinal($1) shl 30);
  FDK_BUF_TYPE_OUTPUT     = (cardinal($2) shl 30);

  FDK_BUF_TYPE_PCM_DATA   = (cardinal($1) shl 16);
  FDK_BUF_TYPE_ANC_DATA   = (cardinal($2) shl 16);
  FDK_BUF_TYPE_BS_DATA    = (cardinal($4) shl 16);

const
  AACDECODER_LIB_VL0      = 3;
  AACDECODER_LIB_VL1      = 2;
  AACDECODER_LIB_VL2      = 0;


(**
 * \brief  AAC decoder error codes.
 *)
type
  AAC_DECODER_ERROR = (
    AAC_DEC_OK      =
    $0000, (*!< No error occurred. Output buffer is valid and error free. *)
    AAC_DEC_OUT_OF_MEMORY =
    $0002, (*!< Heap returned NULL pointer. Output buffer is invalid. *)
    AAC_DEC_UNKNOWN =
    $0005, (*!< Error condition is of unknown reason, or from a another
                   module. Output buffer is invalid. *)

           (* Synchronization errors. Output buffer is invalid. *)
    aac_dec_sync_error_start     = $1000,
    AAC_DEC_TRANSPORT_SYNC_ERROR = $1001, (*!< The transport decoder had
                                              synchronization problems. Do not
                                              exit decoding. Just feed new
                                                bitstream data. *)
    AAC_DEC_NOT_ENOUGH_BITS = $1002, (*!< The input buffer ran out of bits. *)
    aac_dec_sync_error_end = $1FFF,

           (* Initialization errors. Output buffer is invalid. *)
    aac_dec_init_error_start = $2000,
    AAC_DEC_INVALID_HANDLE   =
    $2001, (*!< The handle passed to the function call was invalid (NULL). *)
    AAC_DEC_UNSUPPORTED_AOT =
    $2002, (*!< The AOT found in the configuration is not supported. *)
    AAC_DEC_UNSUPPORTED_FORMAT =
    $2003, (*!< The bitstream format is not supported.  *)
    AAC_DEC_UNSUPPORTED_ER_FORMAT =
    $2004, (*!< The error resilience tool format is not supported. *)
    AAC_DEC_UNSUPPORTED_EPCONFIG =
    $2005, (*!< The error protection format is not supported. *)
    AAC_DEC_UNSUPPORTED_MULTILAYER =
    $2006, (*!< More than one layer for AAC scalable is not supported. *)
    AAC_DEC_UNSUPPORTED_CHANNELCONFIG =
    $2007, (*!< The channel configuration (either number or arrangement) is
                   not supported. *)
    AAC_DEC_UNSUPPORTED_SAMPLINGRATE = $2008, (*!< The sample rate specified in
                                                  the configuration is not
                                                  supported. *)
    AAC_DEC_INVALID_SBR_CONFIG =
    $2009, (*!< The SBR configuration is not supported. *)
    AAC_DEC_SET_PARAM_FAIL = $200A,  (*!< The parameter could not be set. Either
                                         the value was out of range or the
                                         parameter does  not exist. *)
    AAC_DEC_NEED_TO_RESTART = $200B, (*!< The decoder needs to be restarted,
                                         since the required configuration change
                                         cannot be performed. *)
    AAC_DEC_OUTPUT_BUFFER_TOO_SMALL =
    $200C, (*!< The provided output buffer is too small. *)
    aac_dec_init_error_end = $2FFF,

           (* Decode errors. Output buffer is valid but concealed. *)
    aac_dec_decode_error_start = $4000,
    AAC_DEC_TRANSPORT_ERROR    =
    $4001, (*!< The transport decoder encountered an unexpected error. *)
    AAC_DEC_PARSE_ERROR = $4002, (*!< Error while parsing the bitstream. Most
                                     probably it is corrupted, or the system
                                     crashed. *)
    AAC_DEC_UNSUPPORTED_EXTENSION_PAYLOAD =
    $4003, (*!< Error while parsing the extension payload of the bitstream.
                   The extension payload type found is not supported. *)
    AAC_DEC_DECODE_FRAME_ERROR = $4004, (*!< The parsed bitstream value is out of
                                            range. Most probably the bitstream is
                                            corrupt, or the system crashed. *)
    AAC_DEC_CRC_ERROR = $4005,          (*!< The embedded CRC did not match. *)
    AAC_DEC_INVALID_CODE_BOOK = $4006,  (*!< An invalid codebook was signaled.
                                            Most probably the bitstream is corrupt,
                                            or the system  crashed. *)
    AAC_DEC_UNSUPPORTED_PREDICTION =
    $4007, (*!< Predictor found, but not supported in the AAC Low Complexity
                   profile. Most probably the bitstream is corrupt, or has a wrong
                   format. *)
    AAC_DEC_UNSUPPORTED_CCE = $4008, (*!< A CCE element was found which is not
                                         supported. Most probably the bitstream is
                                         corrupt, or has a wrong format. *)
    AAC_DEC_UNSUPPORTED_LFE = $4009, (*!< A LFE element was found which is not
                                         supported. Most probably the bitstream is
                                         corrupt, or has a wrong format. *)
    AAC_DEC_UNSUPPORTED_GAIN_CONTROL_DATA =
    $400A, (*!< Gain control data found but not supported. Most probably the
                   bitstream is corrupt, or has a wrong format. *)
    AAC_DEC_UNSUPPORTED_SBA =
    $400B, (*!< SBA found, but currently not supported in the BSAC profile.
                 *)
    AAC_DEC_TNS_READ_ERROR = $400C, (*!< Error while reading TNS data. Most
                                        probably the bitstream is corrupt or the
                                        system crashed. *)
    AAC_DEC_RVLC_ERROR =
    $400D, (*!< Error while decoding error resilient data. *)
    aac_dec_decode_error_end = $4FFF,
           (* Ancillary data errors. Output buffer is valid. *)
    aac_dec_anc_data_error_start = $8000,
    AAC_DEC_ANC_DATA_ERROR       =
    $8001, (*!< Non severe error concerning the ancillary data handling. *)
    AAC_DEC_TOO_SMALL_ANC_BUFFER = $8002,  (*!< The registered ancillary data
                                               buffer is too small to receive the
                                               parsed data. *)
    AAC_DEC_TOO_MANY_ANC_ELEMENTS = $8003, (*!< More than the allowed number of
                                               ancillary data elements should be
                                               written to buffer. *)
    aac_dec_anc_data_error_end = $8FFF

    );

  (** Macro to identify initialization errors. Output buffer is invalid. *)
  //#define IS_INIT_ERROR(err)                                                    \
  //  ((((err) >= aac_dec_init_error_start) && ((err) <= aac_dec_init_error_end)) \
  //       ? 1                                                                    \
  //       : 0)
  (** Macro to identify decode errors. Output buffer is valid but concealed. *)
  //#define IS_DECODE_ERROR(err)                 \
  //  ((((err) >= aac_dec_decode_error_start) && \
  //    ((err) <= aac_dec_decode_error_end))     \
  //       ? 1                                   \
  //       : 0)
(**
 * Macro to identify if the audio output buffer contains valid samples after
 * calling aacDecoder_DecodeFrame(). Output buffer is valid but can be
 * concealed.
 *)
  //#define IS_OUTPUT_VALID(err) (((err) == AAC_DEC_OK) || IS_DECODE_ERROR(err))

(*! \enum  AAC_MD_PROFILE
 *  \brief The available metadata profiles which are mostly related to downmixing. The values define the arguments
 *         for the use with parameter ::AAC_METADATA_PROFILE.
 *)
  AAC_MD_PROFILE = (
    AAC_MD_PROFILE_MPEG_STANDARD =
    0, (*!< The standard profile creates a mixdown signal based on the
              advanced downmix metadata (from a DSE). The equations and default
              values are defined in ISO/IEC 14496:3 Ammendment 4. Any other
              (legacy) downmix metadata will be ignored. No other parameter will
              be modified.         *)
    AAC_MD_PROFILE_MPEG_LEGACY =
    1, (*!< This profile behaves identical to the standard profile if advanced
                downmix metadata (from a DSE) is available. If not, the
              matrix_mixdown information embedded in the program configuration
              element (PCE) will be applied. If neither is the case, the module
              creates a mixdown using the default coefficients as defined in
              ISO/IEC 14496:3 AMD 4. The profile can be used to support legacy
              digital TV (e.g. DVB) streams.           *)
    AAC_MD_PROFILE_MPEG_LEGACY_PRIO =
    2, (*!< Similar to the ::AAC_MD_PROFILE_MPEG_LEGACY profile but if both
              the advanced (ISO/IEC 14496:3 AMD 4) and the legacy (PCE) MPEG
              downmix metadata are available the latter will be applied.
            *)
    AAC_MD_PROFILE_ARIB_JAPAN =
    3 (*!< Downmix creation as described in ABNT NBR 15602-2. But if advanced
               downmix metadata (ISO/IEC 14496:3 AMD 4) is available it will be
               preferred because of the higher resolutions. In addition the
             metadata expiry time will be set to the value defined in the ARIB
             standard (see ::AAC_METADATA_EXPIRY_TIME).
           *)
    );

(*! \enum  AAC_DRC_DEFAULT_PRESENTATION_MODE_OPTIONS
 *  \brief Options for handling of DRC parameters, if presentation mode is not indicated in bitstream
 *)
  AAC_DRC_DEFAULT_PRESENTATION_MODE_OPTIONS = (
    AAC_DRC_PARAMETER_HANDLING_DISABLED     = -1, (*!< DRC parameter handling
                                                 disabled, all parameters are
                                                 applied as requested. *)
    AAC_DRC_PARAMETER_HANDLING_ENABLED =
    0, (*!< Apply changes to requested DRC parameters to prevent clipping. *)
    AAC_DRC_PRESENTATION_MODE_1_DEFAULT =
    1, (*!< Use DRC presentation mode 1 as default (e.g. for Nordig) *)
    AAC_DRC_PRESENTATION_MODE_2_DEFAULT =
    2  (*!< Use DRC presentation mode 2 as default (e.g. for DTG DBook) *)
    );

(**
 * \brief AAC decoder setting parameters
 *)
  AACDEC_PARAM = (
    AAC_PCM_DUAL_CHANNEL_OUTPUT_MODE =
    $0002, (*!< Defines how the decoder processes two channel signals: \n
                     0: Leave both signals as they are (default). \n
                     1: Create a dual mono output signal from channel 1. \n
                     2: Create a dual mono output signal from channel 2. \n
                     3: Create a dual mono output signal by mixing both channels
                   (L' = R' = 0.5*Ch1 + 0.5*Ch2). *)
    AAC_PCM_OUTPUT_CHANNEL_MAPPING =
    $0003, (*!< Output buffer channel ordering. 0: MPEG PCE style order, 1:
                   WAV file channel order (default). *)
    AAC_PCM_LIMITER_ENABLE =
    $0004,                           (*!< Enable signal level limiting. \n
                                               -1: Auto-config. Enable limiter for all
                                             non-lowdelay configurations by default. \n
                                                0: Disable limiter in general. \n
                                                1: Enable limiter always.
                                               It is recommended to call the decoder
                                             with a AACDEC_CLRHIST flag to reset all
                                             states when      the limiter switch is changed
                                             explicitly. *)
    AAC_PCM_LIMITER_ATTACK_TIME = $0005, (*!< Signal level limiting attack time
                                             in ms. Default configuration is 15
                                             ms. Adjustable range from 1 ms to 15
                                             ms. *)
    AAC_PCM_LIMITER_RELEAS_TIME = $0006, (*!< Signal level limiting release time
                                             in ms. Default configuration is 50
                                             ms. Adjustable time must be larger
                                             than 0 ms. *)
    AAC_PCM_MIN_OUTPUT_CHANNELS =
    $0011, (*!< Minimum number of PCM output channels. If higher than the
                   number of encoded audio channels, a simple channel extension is
                   applied (see note 4 for exceptions). \n -1, 0: Disable channel
                   extension feature. The decoder output contains the same number
                   of channels as the encoded bitstream. \n 1:    This value is
                   currently needed only together with the mix-down feature. See
                            ::AAC_PCM_MAX_OUTPUT_CHANNELS and note 2 below. \n
                      2:    Encoded mono signals will be duplicated to achieve a
                   2/0/0.0 channel output configuration. \n 6:    The decoder
                   tries to reorder encoded signals with less than six channels to
                   achieve a 3/0/2.1 channel output signal. Missing channels will
                   be filled with a zero signal. If reordering is not possible the
                   empty channels will simply be appended. Only available if
                   instance is configured to support multichannel output. \n 8:
                   The decoder tries to reorder encoded signals with less than
                   eight channels to achieve a 3/0/4.1 channel output signal.
                   Missing channels will be filled with a zero signal. If
                   reordering is not possible the empty channels will simply be
                            appended. Only available if instance is configured to
                   support multichannel output.\n NOTE: \n
                       1. The channel signaling (CStreamInfo::pChannelType and
                   CStreamInfo::pChannelIndices) will not be modified. Added empty
                   channels will be signaled with channel type
                          AUDIO_CHANNEL_TYPE::ACT_NONE. \n
                       2. If the parameter value is greater than that of
                   ::AAC_PCM_MAX_OUTPUT_CHANNELS both will be set to the same
                   value. \n
                       3. This parameter will be ignored if the number of encoded
                   audio channels is greater than 8. *)
    AAC_PCM_MAX_OUTPUT_CHANNELS =
    $0012, (*!< Maximum number of PCM output channels. If lower than the
                   number of encoded audio channels, downmixing is applied
                   accordingly (see note 5 for exceptions). If dedicated metadata
                   is available in the stream it will be used to achieve better
                   mixing results. \n -1, 0: Disable downmixing feature. The
                   decoder output contains the same number of channels as the
                   encoded bitstream. \n 1:    All encoded audio configurations
                   with more than one channel will be mixed down to one mono
                   output signal. \n 2:    The decoder performs a stereo mix-down
                   if the number encoded audio channels is greater than two. \n 6:
                   If the number of encoded audio channels is greater than six the
                   decoder performs a mix-down to meet the target output
                   configuration of 3/0/2.1 channels. Only available if instance
                   is configured to support multichannel output. \n 8:    This
                   value is currently needed only together with the channel
                   extension feature. See ::AAC_PCM_MIN_OUTPUT_CHANNELS and note 2
                   below. Only available if instance is configured to support
                   multichannel output. \n NOTE: \n
                       1. Down-mixing of any seven or eight channel configuration
                   not defined in ISO/IEC 14496-3 PDAM 4 is not supported by this
                   software version. \n
                       2. If the parameter value is greater than zero but smaller
                   than ::AAC_PCM_MIN_OUTPUT_CHANNELS both will be set to same
                   value. \n
                       3. This parameter will be ignored if the number of encoded
                   audio channels is greater than 8. *)
    AAC_METADATA_PROFILE =
    $0020, (*!< See ::AAC_MD_PROFILE for all available values. *)
    AAC_METADATA_EXPIRY_TIME = $0021, (*!< Defines the time in ms after which all
                                          the bitstream associated meta-data (DRC,
                                          downmix coefficients, ...) will be reset
                                          to default if no update has been
                                          received. Negative values disable the
                                          feature. *)

    AAC_CONCEAL_METHOD = $0100, (*!< Error concealment: Processing method. \n
                                      0: Spectral muting. \n
                                      1: Noise substitution (see ::CONCEAL_NOISE).
                                    \n 2: Energy interpolation (adds additional
                                    signal delay of one frame, see
                                    ::CONCEAL_INTER. only some AOTs are
                                    supported). \n *)
    AAC_DRC_BOOST_FACTOR =
    $0200, (*!< MPEG-4 / MPEG-D Dynamic Range Control (DRC): Scaling factor
                   for boosting gain values. Defines how the boosting DRC factors
                   (conveyed in the bitstream) will be applied to the decoded
                   signal. The valid values range from 0 (don't apply boost
                   factors) to 127 (fully apply boost factors). Default value is 0
                   for MPEG-4 DRC and 127 for MPEG-D DRC. *)
    AAC_DRC_ATTENUATION_FACTOR = $0201, (*!< MPEG-4 / MPEG-D DRC: Scaling factor
                                            for attenuating gain values. Same as
                                              ::AAC_DRC_BOOST_FACTOR but for
                                            attenuating DRC factors. *)
    AAC_DRC_REFERENCE_LEVEL =
    $0202, (*!< MPEG-4 / MPEG-D DRC: Target reference level / decoder target
                   loudness.\n Defines the level below full-scale (quantized in
                   steps of 0.25dB) to which the output audio signal will be
                   normalized to by the DRC module.\n The parameter controls
                   loudness normalization for both MPEG-4 DRC and MPEG-D DRC. The
                   valid values range from 40 (-10 dBFS) to 127 (-31.75 dBFS).\n
                     Example values:\n
                     124 (-31 dBFS) for audio/video receivers (AVR) or other
                   devices allowing audio playback with high dynamic range,\n 96
                   (-24 dBFS) for TV sets or equivalent devices (default),\n 64
                   (-16 dBFS) for mobile devices where the dynamic range of audio
                   playback is restricted.\n Any value smaller than 0 switches off
                   loudness normalization and MPEG-4 DRC. *)
    AAC_DRC_HEAVY_COMPRESSION =
    $0203, (*!< MPEG-4 DRC: En-/Disable DVB specific heavy compression (aka
                   RF mode). If set to 1, the decoder will apply the compression
                   values from the DVB specific ancillary data field. At the same
                   time the MPEG-4 Dynamic Range Control tool will be disabled. By
                     default, heavy compression is disabled. *)
    AAC_DRC_DEFAULT_PRESENTATION_MODE =
    $0204, (*!< MPEG-4 DRC: Default presentation mode (DRC parameter
                   handling). \n Defines the handling of the DRC parameters boost
                   factor, attenuation factor and heavy compression, if no
                   presentation mode is indicated in the bitstream.\n For options,
                   see ::AAC_DRC_DEFAULT_PRESENTATION_MODE_OPTIONS.\n Default:
                   ::AAC_DRC_PARAMETER_HANDLING_DISABLED *)
    AAC_DRC_ENC_TARGET_LEVEL =
    $0205, (*!< MPEG-4 DRC: Encoder target level for light (i.e. not heavy)
                   compression.\n If known, this declares the target reference
                   level that was assumed at the encoder for calculation of
                   limiting gains. The valid values range from 0 (full-scale) to
                   127 (31.75 dB below full-scale). This parameter is used only
                   with ::AAC_DRC_PARAMETER_HANDLING_ENABLED and ignored
                   otherwise.\n Default: 127 (worst-case assumption).\n *)
    AAC_UNIDRC_SET_EFFECT = $0206, (*!< MPEG-D DRC: Request a DRC effect type for
                                       selection of a DRC set.\n Supported indices
                                       are:\n -1: DRC off. Completely disables
                                       MPEG-D DRC.\n 0: None (default). Disables
                                       MPEG-D DRC, but automatically enables DRC
                                       if necessary to prevent clipping.\n 1: Late
                                       night\n 2: Noisy environment\n 3: Limited
                                       playback range\n 4: Low playback level\n 5:
                                       Dialog enhancement\n 6: General
                                       compression. Used for generally enabling
                                       MPEG-D DRC without particular request.\n *)
    AAC_UNIDRC_ALBUM_MODE =
    $0207, (*!<  MPEG-D DRC: Enable album mode. 0: Disabled (default), 1:
                   Enabled.\n Disabled album mode leads to application of gain
                   sequences for fading in and out, if provided in the
                   bitstream.\n Enabled album mode makes use of dedicated album
                   loudness information, if provided in the bitstream.\n *)
    AAC_QMF_LOWPOWER =
    $0300, (*!< Quadrature Mirror Filter (QMF) Bank processing mode. \n
                     -1: Use internal default. \n
                      0: Use complex QMF data mode. \n
                      1: Use real (low power) QMF data mode. \n *)
    AAC_TPDEC_CLEAR_BUFFER =
    $0603 (*!< Clear internal bit stream buffer of transport layers. The
                  decoder will start decoding at new data passed after this event
                  and any previous data is discarded. *)

    );

(**
 * \brief This structure gives information about the currently decoded audio
 * data. All fields are read-only.
 *)
  PCStreamInfo = ^TCStreamInfo;

  TCStreamInfo = record
    (* These five members are the only really relevant ones for the user. *)
    sampleRate: integer; (*!< The sample rate in Hz of the decoded PCM audio signal. *)
    frameSize: integer;  (*!< The frame size of the decoded PCM audio signal. \n
                         Typically this is: \n
                         1024 or 960 for AAC-LC \n
                         2048 or 1920 for HE-AAC (v2) \n
                         512 or 480 for AAC-LD and AAC-ELD \n
                         768, 1024, 2048 or 4096 for USAC  *)
    numChannels: integer; (*!< The number of output audio channels before the rendering
                        module, i.e. the original channel configuration. *)
    pChannelType: array of AUDIO_CHANNEL_TYPE; (*!< Audio channel type of each output audio channel. *)
    pChannelIndices: array of byte; (*!< Audio channel index for each output audio
                               channel. See ISO/IEC 13818-7:2005(E), 8.5.3.2
                               Explicit channel mapping using a
                               program_config_element() *)
    (* Decoder internal members. *)
    aacSampleRate: integer; (*!< Sampling rate in Hz without SBR (from configuration
                          info) divided by a (ELD) downscale factor if present. *)
    profile: integer; (*!< MPEG-2 profile (from file header) (-1: not applicable (e. g.
                    MPEG-4)).               *)
    aot: AUDIO_OBJECT_TYPE; (*!< Audio Object Type (from ASC): is set to the appropriate value
            for MPEG-2 bitstreams (e. g. 2 for AAC-LC). *)
    channelConfig: integer; (*!< Channel configuration (0: PCE defined, 1: mono, 2:
                          stereo, ...                       *)
    bitRate: integer;          (*!< Instantaneous bit rate.                   *)
    aacSamplesPerFrame: integer;   (*!< Samples per frame for the AAC core (from ASC)
                                 divided by a (ELD) downscale factor if present. \n
                                   Typically this is (with a downscale factor of 1):
                                 \n   1024 or 960 for AAC-LC \n   512 or 480 for
                                 AAC-LD   and AAC-ELD         *)
    aacNumChannels: integer;       (*!< The number of audio channels after AAC core
                                 processing (before PS or MPS processing).       CAUTION: This
                                 are not the final number of output channels! *)
    extAot: AUDIO_OBJECT_TYPE; (*!< Extension Audio Object Type (from ASC)   *)
    extSamplingRate: integer; (*!< Extension sampling rate in Hz (from ASC) divided by
                            a (ELD) downscale factor if present. *)

    outputDelay: cardinal; (*!< The number of samples the output is additionally
                         delayed by.the decoder. *)
    flags: cardinal; (*!< Copy of internal flags. Only to be written by the decoder,
                   and only to be read externally. *)

    epConfig: shortint; (*!< epConfig level (from ASC): only level 0 supported, -1
                       means no ER (e. g. AOT=2, MPEG-2 AAC, etc.)  *)
    (* Statistics *)
    numLostAccessUnits: integer; (*!< This integer will reflect the estimated amount of
                               lost access units in case aacDecoder_DecodeFrame()
                                 returns AAC_DEC_TRANSPORT_SYNC_ERROR. It will be
                               < 0 if the estimation failed. *)

    numTotalBytes: int64; (*!< This is the number of total bytes that have passed
                            through the decoder. *)
    numBadBytes: int64; (*!< This is the number of total bytes that were considered
                    with errors from numTotalBytes. *)
    numTotalAccessUnits: int64;     (*!< This is the number of total access units that
                                have passed through the decoder. *)
    numBadAccessUnits: int64; (*!< This is the number of total access units that
                                were considered with errors from numTotalBytes. *)

    (* Metadata *)
    drcProgRefLev: shortint; (*!< DRC program reference level. Defines the reference
                            level below full-scale. It is quantized in steps of
                            0.25dB. The valid values range from 0 (0 dBFS) to 127
                            (-31.75 dBFS). It is used to reflect the average
                            loudness of the audio in LKFS according to ITU-R BS
                            1770. If no level has been found in the bitstream the
                            value is -1. *)
    drcPresMode: shortint;        (*!< DRC presentation mode. According to ETSI TS 101 154,
                           this field indicates whether   light (MPEG-4 Dynamic Range
                           Control tool) or heavy compression (DVB heavy
                           compression)   dynamic range control shall take priority
                           on the outputs.   For details, see ETSI TS 101 154, table
                           C.33. Possible values are: \n   -1: No corresponding
                           metadata found in the bitstream \n   0: DRC presentation
                           mode not indicated \n   1: DRC presentation mode 1 \n   2:
                           DRC presentation mode 2 \n   3: Reserved *)
    outputLoudness: integer; (*!< Audio output loudness in steps of -0.25 dB. Range: 0
                           (0 dBFS) to 231 (-57.75 dBFS).\n  A value of -1
                           indicates that no loudness metadata is present.\n  If
                           loudness normalization is active, the value corresponds
                           to the target loudness value set with
                           ::AAC_DRC_REFERENCE_LEVEL.\n  If loudness normalization
                           is not active, the output loudness value corresponds to
                           the loudness metadata given in the bitstream.\n
                             Loudness metadata can originate from MPEG-4 DRC or
                           MPEG-D DRC. *)

  end;

  HANDLE_AACDECODER = ^AAC_DECODER_INSTANCE;

  AAC_DECODER_INSTANCE = record
    HANDLE_AACDECODER: Pointer; (*!< Pointer to a AAC decoder instance. *)
  end;

 (**
 * \brief Initialize ancillary data buffer.
 *
 * \param self    AAC decoder handle.
 * \param buffer  Pointer to (external) ancillary data buffer.
 * \param size    Size of the buffer pointed to by buffer.
 * \return        Error code.
 *)
var

  aacDecoder_AncDataInit: function(self: HANDLE_AACDECODER; buffer: PByte; size: integer): AAC_DECODER_ERROR;
  cdecl;

(**
 * \brief Get one ancillary data element.
 *
 * \param self   AAC decoder handle.
 * \param index  Index of the ancillary data element to get.
 * \param ptr    Pointer to a buffer receiving a pointer to the requested
 * ancillary data element.
 * \param size   Pointer to a buffer receiving the length of the requested
 * ancillary data element.
 * \return       Error code.
 *)
  aacDecoder_AncDataGet: function(self: HANDLE_AACDECODER; index: integer; var ptr: PByte; var size: integer): AAC_DECODER_ERROR;
  cdecl;

(**
 * \brief Set one single decoder parameter.
 *
 * \param self   AAC decoder handle.
 * \param param  Parameter to be set.
 * \param value  Parameter value.
 * \return       Error code.
 *)
  aacDecoder_SetParam: function(const self: HANDLE_AACDECODER; const param: AACDEC_PARAM; const Value: integer): AAC_DECODER_ERROR;
  cdecl;

(**
 * \brief              Get free bytes inside decoder internal buffer.
 * \param self         Handle of AAC decoder instance.
 * \param pFreeBytes   Pointer to variable receiving amount of free bytes inside
 * decoder internal buffer.
 * \return             Error code.
 *)
  aacDecoder_GetFreeBytes: function(const self: HANDLE_AACDECODER; var pFreeBytes: cardinal): AAC_DECODER_ERROR;
  cdecl;

(**
 * \brief               Open an AAC decoder instance.
 * \param transportFmt  The transport type to be used.
 * \param nrOfLayers    Number of transport layers.
 * \return              AAC decoder handle.
 *)
  aacDecoder_Open: function(transportFmt: TRANSPORT_TYPE; nrOfLayers: cardinal): HANDLE_AACDECODER;
  cdecl;

(**
 * \brief Explicitly configure the decoder by passing a raw AudioSpecificConfig
 * (ASC) or a StreamMuxConfig (SMC), contained in a binary buffer. This is
 * required for MPEG-4 and Raw Packets file format bitstreams as well as for
 * LATM bitstreams with no in-band SMC. If the transport format is LATM with or
 * without LOAS, configuration is assumed to be an SMC, for all other file
 * formats an ASC.
 *
 * \param self    AAC decoder handle.
 * \param conf    Pointer to an unsigned char buffer containing the binary
 * configuration buffer (either ASC or SMC).
 * \param length  Length of the configuration buffer in bytes.
 * \return        Error code.
 *)
  aacDecoder_ConfigRaw: function(self: HANDLE_AACDECODER; conf: Pointer; const length: PCardinal): AAC_DECODER_ERROR;
  cdecl;

(**
 * \brief Submit raw ISO base media file format boxes to decoder for parsing
 * (only some box types are recognized).
 *
 * \param self    AAC decoder handle.
 * \param buffer  Pointer to an unsigned char buffer containing the binary box
 * data (including size and type, can be a sequence of multiple boxes).
 * \param length  Length of the data in bytes.
 * \return        Error code.
 *)
  aacDecoder_RawISOBMFFData: function(self: HANDLE_AACDECODER; buffer: PByte; length: cardinal): AAC_DECODER_ERROR;
  cdecl;

(**
 * \brief Fill AAC decoder's internal input buffer with bitstream data from the
 * external input buffer. The function only copies such data as long as the
 * decoder-internal input buffer is not full. So it grabs whatever it can from
 * pBuffer and returns information (bytesValid) so that at a subsequent call of
 * %aacDecoder_Fill(), the right position in pBuffer can be determined to grab
 * the next data.
 *
 * \param self        AAC decoder handle.
 * \param pBuffer     Pointer to external input buffer.
 * \param bufferSize  Size of external input buffer. This argument is required
 * because decoder-internally we need the information to calculate the offset to
 * pBuffer, where the next available data is, which is then
 * fed into the decoder-internal buffer (as much as
 * possible). Our example framework implementation fills the
 * buffer at pBuffer again, once it contains no available valid bytes anymore
 * (meaning bytesValid equal 0).
 * \param bytesValid  Number of bitstream bytes in the external bitstream buffer
 * that have not yet been copied into the decoder's internal bitstream buffer by
 * calling this function. The value is updated according to
 * the amount of newly copied bytes.
 * \return            Error code.
 *)
  aacDecoder_Fill: function(self: HANDLE_AACDECODER; pBuffer: PByte; var bufferSize: cardinal;
  var bytesValid: cardinal): AAC_DECODER_ERROR;
  cdecl;

const
  (** Flag for aacDecoder_DecodeFrame(): Trigger the built-in error concealment
   * module to generate a substitute signal for one lost frame. New input data
   * will not be considered.
   *)
  AACDEC_CONCEAL = 1;
  (** Flag for aacDecoder_DecodeFrame(): Flush all filterbanks to get all delayed
   * audio without having new input data. Thus new input data will not be
   * considered.
   *)
  AACDEC_FLUSH   = 2;
  (** Flag for aacDecoder_DecodeFrame(): Signal an input bit stream data
   * discontinuity. Resync any internals as necessary.
   *)
  AACDEC_INTR    = 4;
  (** Flag for aacDecoder_DecodeFrame(): Clear all signal delay lines and history
   * buffers. CAUTION: This can cause discontinuities in the output signal.
   *)
  AACDEC_CLRHIST = 8;

(**
 * \brief               Decode one audio frame
 *
 * \param self          AAC decoder handle.
 * \param pTimeData     Pointer to external output buffer where the decoded PCM
 * samples will be stored into.
 * \param timeDataSize  Size of external output buffer.
 * \param flags         Bit field with flags for the decoder: \n
 *                      (flags & AACDEC_CONCEAL) == 1: Do concealment. \n
 *                      (flags & AACDEC_FLUSH) == 2: Discard input data. Flush
 * filter banks (output delayed audio). \n (flags & AACDEC_INTR) == 4: Input
 * data is discontinuous. Resynchronize any internals as
 * necessary. \n (flags & AACDEC_CLRHIST) == 8: Clear all signal delay lines and
 * history buffers.
 * \return              Error code.
 *)
var

  aacDecoder_DecodeFrame: function(self: HANDLE_AACDECODER; pTimeData: PSmallInt; const timeDataSize: integer;
  const flags: cardinal): AAC_DECODER_ERROR;
  cdecl;

(**
 * \brief       De-allocate all resources of an AAC decoder instance.
 *
 * \param self  AAC decoder handle.
 * \return      void.
 *)
  aacDecoder_Close: procedure(self: HANDLE_AACDECODER);
  cdecl;

(**
 * \brief       Get CStreamInfo handle from decoder.
 *
 * \param self  AAC decoder handle.
 * \return      Reference to requested CStreamInfo.
 *)
  aacDecoder_GetStreamInfo: function(self: HANDLE_AACDECODER): PCStreamInfo;
  cdecl;

(**
 * \brief       Get decoder library info.
 *
 * \param info  Pointer to an allocated LIB_INFO structure.
 * \return      0 on success.
 *)
  aacDecoder_GetLibInfo: function(var info: array of LIB_INFO): integer;
  cdecl;

var
  ad_Handle: TLibHandle = dynlibs.NilHandle;
  {$if defined(cpu32) and defined(windows)} // try load dependency if not in /windows/system32/
  gc_Handle :TLibHandle=dynlibs.NilHandle;
  {$endif}

var
  ReferenceCounter: cardinal = 0;

function ad_IsLoaded: Boolean; inline;

function ad_Load(const libfilename: string): Boolean;

procedure ad_Unload();


implementation

function ad_IsLoaded: Boolean;
begin
  Result := (ad_Handle <> dynlibs.NilHandle);
end;

procedure ad_Unload;
begin
  // < Reference counting
  if ReferenceCounter > 0 then
    Dec(ReferenceCounter);
  if ReferenceCounter > 0 then
    Exit;
  // >
  if ad_IsLoaded then
  begin
    DynLibs.UnloadLibrary(ad_Handle);
    ad_Handle := DynLibs.NilHandle;
    {$if defined(cpu32) and defined(windows)}
    if gc_Handle <> DynLibs.NilHandle then begin
    DynLibs.UnloadLibrary(gc_Handle);
    gc_Handle:=DynLibs.NilHandle;
    end;
    {$endif}
  end;
end;

function ad_Load(const libfilename: string): Boolean;
var
  thelib, thelibgcc: string;
begin
  Result := False;
  if ad_Handle <> 0 then
  begin
    Inc(ReferenceCounter);
    Result := True; {is it already there ?}
  end
  else
  begin
   {$if defined(cpu32) and defined(windows)}
   if Length(libfilename) = 0 then thelibgcc := 'libgcc_s_dw2-1.dll' else
   thelibgcc := IncludeTrailingBackslash(ExtractFilePath(libfilename)) + 'libgcc_s_dw2-1.dll';
   gc_Handle:= DynLibs.SafeLoadLibrary(thelibgcc);
   {$endif}
   {go & load the library}
    if Length(libfilename) = 0 then
      thelib := libfdk_aac
    else
      thelib := libfilename;
    ad_Handle := DynLibs.SafeLoadLibrary(thelib); // obtain the handle we want
    if ad_Handle <> DynLibs.NilHandle then
    begin {now we tie the functions to the VARs from above}

      Pointer(aacDecoder_Fill)          := DynLibs.GetProcedureAddress(ad_Handle, PChar('aacDecoder_Fill'));
      Pointer(aacDecoder_DecodeFrame)   := DynLibs.GetProcedureAddress(ad_Handle, PChar('aacDecoder_DecodeFrame'));
      Pointer(aacDecoder_GetStreamInfo) := DynLibs.GetProcedureAddress(ad_Handle, PChar('aacDecoder_GetStreamInfo'));
      Pointer(aacDecoder_Open)          := DynLibs.GetProcedureAddress(ad_Handle, PChar('aacDecoder_Open'));
      Pointer(aacDecoder_SetParam)      := DynLibs.GetProcedureAddress(ad_Handle, PChar('aacDecoder_SetParam'));
      Pointer(aacDecoder_Close)         := DynLibs.GetProcedureAddress(ad_Handle, PChar('aacDecoder_Close'));

    end;
    Result           := ad_IsLoaded;
    ReferenceCounter := 1;
  end;

end;

function TT_IS_PACKET(x: TRANSPORT_TYPE): Boolean;
begin
  Result := ((x = TRANSPORT_TYPE.TT_MP4_RAW) or (x = TRANSPORT_TYPE.TT_DRM) or (x = TRANSPORT_TYPE.TT_MP4_LATM_MCP0) or (x = TRANSPORT_TYPE.TT_MP4_LATM_MCP1));
end;

function CAN_DO_PS(aot: AUDIO_OBJECT_TYPE): Boolean;
begin
  Result := ((aot = AUDIO_OBJECT_TYPE.AOT_AAC_LC) or (aot = AUDIO_OBJECT_TYPE.AOT_SBR) or (aot = AUDIO_OBJECT_TYPE.AOT_PS) or (aot = AUDIO_OBJECT_TYPE.AOT_ER_BSAC) or (aot = AUDIO_OBJECT_TYPE.AOT_DRM_AAC));
end;

function IS_USAC(aot: AUDIO_OBJECT_TYPE): Boolean;
begin
  Result := aot = AUDIO_OBJECT_TYPE.AOT_USAC;
end;

function IS_LOWDELAY(aot: AUDIO_OBJECT_TYPE): Boolean;
begin
  Result := (aot = AUDIO_OBJECT_TYPE.AOT_ER_AAC_LD) or (aot = AUDIO_OBJECT_TYPE.AOT_ER_AAC_ELD);
end;

function IS_CHANNEL_ELEMENT(elementId: MP4_ELEMENT_ID): Boolean;
begin
  Result := (elementId = MP4_ELEMENT_ID.ID_SCE) or (elementId = MP4_ELEMENT_ID.ID_CPE) or (elementId = MP4_ELEMENT_ID.ID_LFE) or (elementId = MP4_ELEMENT_ID.ID_USAC_SCE) or
    (elementId = MP4_ELEMENT_ID.ID_USAC_CPE) or (elementId = MP4_ELEMENT_ID.ID_USAC_LFE);
end;

function IS_MP4_CHANNEL_ELEMENT(elementId: MP4_ELEMENT_ID): Boolean;
begin
  Result := (elementId = MP4_ELEMENT_ID.ID_SCE) or (elementId = MP4_ELEMENT_ID.ID_CPE) or (elementId = MP4_ELEMENT_ID.ID_LFE);
end;

function IS_USAC_CHANNEL_ELEMENT(elementId: MP4_ELEMENT_ID): Boolean;
begin
  Result := (elementId = MP4_ELEMENT_ID.ID_USAC_SCE) or (elementId = MP4_ELEMENT_ID.ID_USAC_CPE) or (elementId = MP4_ELEMENT_ID.ID_USAC_LFE);
end;

function LIB_VERSION(lev0: byte; lev1: byte; lev2: byte): integer;
begin
  Result := (lev0 shl 24) or (lev1 shl 16) or (lev2 shl 8);
end;

function LIB_VERSION_STRING(info: LIB_INFO): string;
begin
  Result   := string(info.versionStr);
  if info.versionStr = '' then
    Result := Format('%d.%d.%d', [(info.versionStr), ((info.version shr 24) and $ff), ((info.version shr 16) and $ff), ((info.version shr 8) and $ff)]);
end;

(** Initialize library info. *)
procedure FDKinitLibInfo(var info: array of LIB_INFO);
var
  i: integer;
begin
  for i := 0 to integer(FDK_MODULE_ID.FDK_MODULE_LAST) - 1 do
    info[i].module_id := FDK_MODULE_ID.FDK_NONE;
end;

(** Aquire supported features of library. *)
function FDKlibInfo_getCapabilities(const info: array of LIB_INFO; module_id: FDK_MODULE_ID): cardinal;
var
  i: integer;
begin
  Result := 0;
  for i  := 0 to integer(FDK_MODULE_ID.FDK_MODULE_LAST) - 1 do
    if Info[i].module_id = module_id then
    begin
      Result := Info[i].flags;
      break;
    end;
end;


function FDKlibInfo_lookup(const info: array of LIB_INFO; module_id: FDK_MODULE_ID): integer;
var
  i: integer;
begin
  Result := -1;
  for i  := 0 to integer(FDK_MODULE_ID.FDK_MODULE_LAST) - 1 do
    if Info[i].module_id = module_id then
    begin
      Result := -1;
      Exit;
    end
    else if Info[i].module_id = FDK_MODULE_ID.FDK_NONE then
    begin
      Result := i;
      Exit;
    end
    else if i = integer(FDK_MODULE_ID.FDK_MODULE_LAST) then
    begin
      Result := -1;
      Exit;
    end;
end;


end.

