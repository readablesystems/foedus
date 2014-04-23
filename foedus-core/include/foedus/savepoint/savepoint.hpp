/*
 * Copyright (c) 2014, Hewlett-Packard Development Company, LP.
 * The license and distribution terms for this file are placed in LICENSE.txt.
 */
#ifndef FOEDUS_SAVEPOINT_SAVEPOINT_HPP_
#define FOEDUS_SAVEPOINT_SAVEPOINT_HPP_
#include <foedus/cxx11.hpp>
#include <foedus/externalize/externalizable.hpp>
#include <foedus/log/log_id.hpp>
#include <foedus/xct/epoch.hpp>
#include <vector>
namespace foedus {
namespace savepoint {
/**
 * @brief The information we maintain in savepoint manager and externalize to a file.
 * @ingroup SAVEPOINT
 * @details
 * This object is a very compact representation of \e progress of the entire engine.
 * This object holds only a few integers per module to denote upto what we are \e surely done.
 * We update this object for each epoch-based group commit and write out this as an xml
 * durably and atomically.
 */
struct Savepoint CXX11_FINAL : public virtual externalize::Externalizable {
    /**
     * Constructs an empty savepoint.
     */
    Savepoint();

    /**
     * @brief Current epoch of the entire engine.
     * @details
     * This value is advanced by transaction manager periodically.
     * This is equal or larger than all other epoch values below.
     */
    xct::Epoch::EpochInteger            current_epoch_;

    /**
     * @brief Latest epoch whose logs were all flushed to disk.
     * @details
     * Upto this epoch, we can guarantee durability. In other words, transactions
     * are not deemed as "done" until this value reaches their epoch values issued on commit time.
     * While the engine restarts, all log entries in log files after this epoch are \b truncated
     * because there might be some logger that did not finish its writing.
     */
    xct::Epoch::EpochInteger            durable_epoch_;


    // for all the following, index is LoggerId

    /**
     * @brief Ordinal of the oldest active log file in each logger.
     * @invariant oldest_log_files_[x] <= current_log_files_[x]
     * @details
     * Each logger writes out files suffixed with ordinal (eg ".0", ".1"...).
     * The older logs files are deactivated and deleted after log gleaner consumes them.
     * This variable indicates the oldest active file for each logger.
     */
    std::vector<log::LogFileOrdinal>    oldest_log_files_;

    /** Indicates the inclusive beginning of active region in the oldest log file. */
    std::vector<uint64_t>               oldest_log_files_offset_begin_;

    /** Indicates the log file each logger is currently appending to. */
    std::vector<log::LogFileOrdinal>    current_log_files_;

    /**
     * Indicates the exclusive end of durable region in the current log file.
     * In other words, epochs are larger than durable_epoch_ from this offset.
     * During restart, current log files are truncated to this size to discard incomplete logs.
     */
    std::vector<uint64_t>               current_log_files_offset_durable_;

    EXTERNALIZABLE(Savepoint);
};
}  // namespace savepoint
}  // namespace foedus
#endif  // FOEDUS_SAVEPOINT_SAVEPOINT_HPP_