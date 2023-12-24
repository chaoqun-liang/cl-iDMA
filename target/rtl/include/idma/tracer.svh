// Copyright 2023 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51

// Authors:
// - Thomas Benz <tbenz@iis.ee.ethz.ch>

// Macro holding all the resources for the iDMA backend tracer
`ifndef IDMA_TRACER_SVH_
`define IDMA_TRACER_SVH_

// largest type to trace
`define IDMA_TRACER_MAX_TYPE_WIDTH 1024
`define IDMA_TRACER_MAX_TYPE logic [`IDMA_TRACER_MAX_TYPE_WIDTH-1:0]

// string assembly function
`define IDMA_TRACER_STR_ASSEMBLY(__dict, __cond) \
    if(__cond) begin \
        trace = $sformatf("%s'%s':{", trace, `"__dict`"); \
        foreach(__dict``[key]) trace = $sformatf("%s'%s': 0x%0x,", trace, key, __dict``[key]); \
        trace = $sformatf("%s},", trace); \
    end

// helper to clear a condition
`define IDMA_TRACER_CLEAR_COND(__cond) \
    if(__cond) begin \
        __cond = ~__cond; \
    end

// The tracer for the rw_axi_rw_axis iDMA
`define IDMA_TRACER_RW_AXI_RW_AXIS(__backend_inst, __out_f) \
`ifndef SYNTHESYS \
`ifndef VERILATOR \
    initial begin : inital_tracer_rw_axi_rw_axis \
        automatic bit first_iter = 1; \
        automatic integer tf; \
        automatic `IDMA_TRACER_MAX_TYPE cnst [string]; \
        automatic `IDMA_TRACER_MAX_TYPE meta [string]; \
        automatic `IDMA_TRACER_MAX_TYPE busy [string]; \
        automatic `IDMA_TRACER_MAX_TYPE bus [string]; \
        automatic string trace; \
        #0; \
        tf = $fopen(__out_f, "w"); \
        $display("[iDMA Tracer] Logging %s to %s", `"__backend_inst`", __out_f); \
        forever begin \
            @(posedge __backend_inst``.clk_i); \
            if(__backend_inst``.rst_ni & |__backend_inst``.busy_o) begin \
                /* Trace */ \
                trace = "{"; \
                /* Constants */ \
                cnst = '{ \
                    "inst"               : `"__backend_inst`", \
                    "identifier"         : "rw_axi_rw_axis", \
                    "data_width"         : __backend_inst``.DataWidth, \
                    "addr_width"         : __backend_inst``.AddrWidth, \
                    "user_width"         : __backend_inst``.UserWidth, \
                    "axi_id_width"       : __backend_inst``.AxiIdWidth, \
                    "num_ax_in_flight"   : __backend_inst``.NumAxInFlight, \
                    "buffer_depth"       : __backend_inst``.BufferDepth, \
                    "tf_len_width"       : __backend_inst``.TFLenWidth, \
                    "mem_sys_depth"      : __backend_inst``.MemSysDepth, \
                    "combined_shifter"   : __backend_inst``.CombinedShifter, \
                    "rw_coupling_avail"  : __backend_inst``.RAWCouplingAvail, \
                    "mask_invalid_data"  : __backend_inst``.MaskInvalidData, \
                    "hardware_legalizer" : __backend_inst``.HardwareLegalizer, \
                    "reject_zero_tfs"    : __backend_inst``.RejectZeroTransfers, \
                    "error_cap"          : __backend_inst``.ErrorCap, \
                    "print_fifo_info"    : __backend_inst``.PrintFifoInfo \
                }; \
                meta = '{ \
                    "time" : $time() \
                }; \
                busy = '{ \
                    "buffer"      : __backend_inst``.busy_o.buffer_busy, \
                    "r_dp"        : __backend_inst``.busy_o.r_dp_busy, \
                    "w_dp"        : __backend_inst``.busy_o.w_dp_busy, \
                    "r_leg"       : __backend_inst``.busy_o.r_leg_busy, \
                    "w_leg"       : __backend_inst``.busy_o.w_leg_busy, \
                    "eh_fsm"      : __backend_inst``.busy_o.eh_fsm_busy, \
                    "eh_cnt"      : __backend_inst``.busy_o.eh_cnt_busy, \
                    "raw_coupler" : __backend_inst``.busy_o.raw_coupler_busy \
                }; \
                bus = '{ \
                    "axi_rsp_valid": __backend_inst``.axi_read_rsp_i.r_valid, \
                    "axi_rsp_ready": __backend_inst``.axi_read_req_o.r_ready, \
                    "axis_rsp_valid": __backend_inst``.axi_stream_read_rsp_i.tvalid, \
                    "axis_rsp_ready": __backend_inst``.axi_stream_read_req_o.tready, \
                    "axis_rsp_strobe": __backend_inst``.axi_stream_read_rsp_i.t.strb, \
                    "axi_req_valid": __backend_inst``.axi_write_req_o.w_valid, \
                    "axi_req_ready": __backend_inst``.axi_write_rsp_i.w_ready, \
                    "axi_req_strobe": __backend_inst``.axi_write_req_o.w.strb, \
                    "axis_req_valid": __backend_inst``.axi_stream_write_req_o.tvalid, \
                    "axis_req_ready": __backend_inst``.axi_stream_write_rsp_i.tready, \
                    "axis_req_strobe": __backend_inst``.axi_stream_write_req_o.t.strb \
                }; \
                /* Assembly */ \
                `IDMA_TRACER_STR_ASSEMBLY(cnst, first_iter); \
                `IDMA_TRACER_STR_ASSEMBLY(meta, 1); \
                `IDMA_TRACER_STR_ASSEMBLY(busy, 1); \
                `IDMA_TRACER_STR_ASSEMBLY(bus, 1); \
                `IDMA_TRACER_CLEAR_COND(first_iter); \
                /* Commit */ \
                $fwrite(tf, $sformatf("%s}\n", trace)); \
            end \
        end \
    end \
`endif \
`endif

`endif

