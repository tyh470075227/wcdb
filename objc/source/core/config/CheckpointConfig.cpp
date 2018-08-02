/*
 * Tencent is pleased to support the open source community by making
 * WCDB available.
 *
 * Copyright (C) 2017 THL A29 Limited, a Tencent company.
 * All rights reserved.
 *
 * Licensed under the BSD 3-Clause License (the "License"); you may not use
 * this file except in compliance with the License. You may obtain a copy of
 * the License at
 *
 *       https://opensource.org/licenses/BSD-3-Clause
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#include <WCDB/Assertion.hpp>
#include <WCDB/Core.h>
#include <mutex>

namespace WCDB {

static_assert(CheckpointConfig::framesForPassive < CheckpointConfig::framesForFull, "");

CheckpointConfig::CheckpointConfig(const std::string& name, CheckpointQueue* queue)
: Config(name)
, m_checkpointTruncate(StatementPragma().pragma(Pragma::walCheckpoint()).to("TRUNCATE"))
, m_queue(queue)
{
    WCTInnerAssert(m_queue != nullptr);
}

bool CheckpointConfig::invoke(Handle* handle)
{
    handle->setNotificationWhenCommitted(
    0, name, std::bind(&CheckpointConfig::onCommitted, this, std::placeholders::_1, std::placeholders::_2));
    return true;
}

bool CheckpointConfig::onCommitted(Handle* handle, int frames)
{
    if (frames > framesForPassive) {
        if (frames > framesForFull) {
            if (handle->execute(m_checkpointTruncate)) {
                m_queue->remove(handle->path);
            }
        } else {
            m_queue->put(handle->path, 1.0, frames);
        }
    } else {
        m_queue->put(handle->path, 10.0, frames);
    }
    return true;
}

} //namespace WCDB
