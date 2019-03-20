@rem Copyright 2019 The Bazel Authors. All rights reserved.
@rem
@rem Licensed under the Apache License, Version 2.0 (the "License");
@rem you may not use this file except in compliance with the License.
@rem You may obtain a copy of the License at
@rem
@rem    http://www.apache.org/licenses/LICENSE-2.0
@rem
@rem Unless required by applicable law or agreed to in writing, software
@rem distributed under the License is distributed on an "AS IS" BASIS,
@rem WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
@rem See the License for the specific language governing permissions and
@rem limitations under the License.

@echo off

if not defined SA_FOO ( exit /b 1 )
if not defined SA_GEN1 ( exit /b 1 )
if not defined SA_OUT1 ( exit /b 1 )
type "%SA_FOO%" "%SA_GEN1%" > "%SA_OUT1%" 2>nul
if "%errorlevel%" neq "0" ( exit /b 1 )

if not defined SA_BAR ( exit /b 1 )
if not defined SA_GEN2 ( exit /b 1 )
if not defined SA_OUT2 ( exit /b 1 )
echo %SA_BAR% %SA_GEN2% > "%SA_OUT2%" 2>nul
if "%errorlevel%" neq "0" ( exit /b 1 )
