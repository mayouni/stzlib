# This file loads the BASE layer of SoftanzaLib (along with its CORE layer)

# Giving priority to user code config (suggested by Mahmoud)
if NOT isGlobal(:$aStzLibConfig ) #TODO // Make it a stzlibconfig.ring file
    $aStzLibConfig = []
ok

// tz0 = clock()

# Loding the files related to the CORE layer

    load "../core/stzCore.ring" 

# Loading files related tp the COMMON module

    load "common/stzIntSeq.ring"
    load "common/stzCounter.ring"
    load "common/stzFuncs.ring"

    load "common/stzOccurrences.ring"
    load "common/stzRingFuncs.ring"

    load "common/stzRingLibs.ring"
    load "common/stzPrimitives.ring"
    load "common/stzNamedParams.ring"
    load "common/stzSmallFuncs.ring"
    load "common/stzSplitter.ring"

    load "common/stzCCode.ring"
    load "common/stzNamedVars.ring"

# Loading files related to the DATA module

    load "data/stzCharData.ring"
    load "data/stzUnicodeData.ring"
    load "data/stzLocaleData.ring"
    load "data/stzRegexData.ring"
    load "data/stzRandomData.ring"
    load "data/stzSystemCallData.ring"

    # stzDatabase -- the sqlite-backed data store (data domain, R7)
    load "data/stzDatabase.ring"

# Loading files related to the OBJECT module

    load "object/stzObject.ring"
    load "object/stzObjectHistory.ring"

    load "object/stzListOfObjects.ring"
    load "object/stzListOfNamedObjects.ring"
    load "object/stzNullObject.ring"
    load "object/stzTrueObject.ring"
    load "object/stzFalseObject.ring"

# Loading files related to the NUMBER module

    load "number/stzNumber.ring" #TODO Check compatibiiliy with stkNumber in CORE layer
    load "number/stzListOfNumbers.ring"
    load "number/stzNumBuffer.ring"   # numbers that LIVE in the engine (residency)
    load "number/stzPairOfNumbers.ring"

    load "number/stzBinaryNumber.ring"
    load "number/stzDecimalToBinary.ring"
    load "number/stzHexNumber.ring"
    load "number/stzOctalNumber.ring"

    load "number/stzListOfBytes.ring"

    load "number/stzRandom.ring"
    load "number/stzSciNumber.ring"

    # stzFastPro deprecated 2026-06-13 (M-DEP1): wrapped the RingFastPro
    # C++ extension whose only consumer was its own test suite. Engine
    # stzMatrix covers the hot paths; the file is preserved under
    # base/archive/number/ for reference.
    load "number/stzMatrix.ring"
    load "number/stzComplex.ring"
    load "number/stzFourier.ring"
    load "number/stzVectorIndex.ring"

    # gpu/ -- the declarative GPU surface (G4, SOFTANZA_GPU_PLAN.md)
    load "gpu/stzKernelMaker.ring"
    load "gpu/stzGpuBuffer.ring"
    load "gpu/stzGpu.ring"

    # graphics/ -- the declarative drawing surface (GR4,
    # SOFTANZA_GRAPHICS_PLAN.md). stzColor first: the others take colours.
    load "graphics/stzColor.ring"
    load "graphics/stzFont.ring"
    load "graphics/stzMesh.ring"
    load "graphics/stzCanvas.ring"
    # graphviz's 24-shape node vocabulary, composed from canvas primitives
    load "graphics/stzNodeShape.ring"
    # a theme is DATA: role steps resolved to hex, exportable to CSS/JSON/Ring
    load "graphics/stzTheme.ring"
    load "graphics/stzScene.ring"
    load "graphics/stzPlotCanvas.ring"
    load "graphics/stzTreeCanvas.ring"
    load "graphics/stzMaterialMaker.ring"
    # last: it takes a canvas or a scene, so both must already exist
    # a graph draws itself; needs stzCanvas above it
    load "graphics/stzGraphCanvas.ring"
    load "graphics/stzWindow.ring"
    # the frame graph: passes and resources as a graph. Uses stzGraph and
    # stzRuleReport at RUNTIME, so it may load before them.
    load "graphics/stzFrameGraph.ring"

    # gui/ -- the widget, layout and interaction layer (G1,
    # base/gui/SOFTANZA_GUI_PLAN.md). Loads AFTER graphics because a panel
    # draws into an stzCanvas; the plane above graphics, not beside it.
    # A machine without stz_gui.dll still loads this -- StzGuiAvailable()
    # answers FALSE and every other graphics path keeps working.
    load "gui/stzGui.ring"

    # sound/ -- the declarative sound surface (SN4, SOFTANZA_SOUND_PLAN.md).
    # stzSound needs no hardware at all; stzMicrophone reports honestly when
    # there is no input to record from.
    load "sound/stzSoundGrid.ring"
    load "sound/stzSoundPlot.ring"
    load "sound/stzSound.ring"
    load "sound/stzSoundGraph.ring"
    load "sound/stzSoundTransport.ring"
    load "sound/stzVoicePool.ring"
    # the SEMANTIC layer -- above the graph; needs the pool, so it loads after it
    # the VOICE face (VC2) -- text in, a stzSound out. Needs the transport
    # for its non-blocking path, so it loads after it.
    load "sound/stzVoice.ring"
    # the other door: sound -> text. Closed grammar only -- VC3 measured why.
    load "sound/stzListener.ring"
    load "sound/stzEarcons.ring"
    load "sound/stzMicrophone.ring"

    # the material graph: a material AS a graph, emitting the material
    # language. Same runtime-only dependency on stzGraph and stzRuleReport.
    load "graphics/stzMaterialGraph.ring"
    load "number/stzPolynomial.ring"
    load "number/stzMathFunction.ring"
    load "number/stzObjective.ring"
    load "number/stzPCA.ring"
    load "number/stzEmbedding.ring"

# Loading files related to the STRING module

    load "string/stzStringFunc.ring"
    load "string/stzString.ring"

    load "string/stzStringList.ring"
    load "string/stzStringBoxed.ring"
    load "string/stzStringChar.ring"
    load "string/stzStringCharList.ring"
    load "string/stzStringUnicodeList.ring"
    load "string/stzStringSubString.ring"

    load "string/stzStringText.ring"

    # linguistic/ -- TEXT PROCESSING / NLP as a domain (R3): stzText is
    # its ENTRY OBJECT (promoted from natural/, which keeps
    # language-as-code only). It is
    # loaded here (early) because it depends on stzStringText, loaded just above.
    load "linguistic/stzParseTree.ring"
    load "linguistic/stzText.ring"
    # stzListOfTexts (from stzStringList): a list of texts (sentences carry
    # meaning) with the natural/meaning list ops. SentencesQ() returns it.
    load "linguistic/stzListOfTexts.ring"
    load "linguistic/stzCorpus.ring"

    # Modern / neural domain (base/neural/): stzNeural base -> engine + model
    load "neural/stzNeural.ring"
    load "neural/stzNeuralEngine.ring"
    load "neural/stzNeuralModel.ring"
    load "neural/stzSemanticIndex.ring"
    load "neural/stzOutputSchema.ring"
    load "neural/stzLLMFunction.ring"

    # Reflection: self-describing objects -- harvest a class's methods + docs from
    # source, then Ask()/ExplainMethod() via the neural tier (near-natural
    # programming, no heavy LLM). Loaded after neural (uses its globals at runtime).
    load "reflect/stzReflectFuncs.ring"

    # meta/ -- the library's knowledge of ITSELF as a domain (R2):
    # self-doc (promoted from reflect/, which keeps the parsing
    # primitives), structure (stzCodeGraph), runnable house rules
    # (stzCodeRules), governance checks + signable predicate sets.
    load "meta/stzSelfDoc.ring"
    load "meta/stzLibDoc.ring"
    load "meta/stzCodeGraph.ring"
    load "meta/stzRingCodeGraph.ring"
    load "meta/stzPyCodeGraph.ring"
    load "meta/stzJsCodeGraph.ring"
    load "meta/stzCodeRules.ring"
    load "meta/stzGovernanceChecks.ring"
    load "meta/stzPredicateSet.ring"

    load "string/stzWordStream.ring"

    # Modular subclasses

    load "string/stzStringFinder.ring"
    load "string/stzStringReplacer.ring"
    load "string/stzStringSplitter.ring"

    load "string/stzStringBounder.ring"
    load "string/stzStringChecker.ring"
    load "string/stzStringFormatter.ring"

    load "string/stzStringWalker.ring"
    load "string/stzStringVisualizer.ring"

    load "string/stzStringLines.ring"
    load "string/stzStringWords.ring"
    load "string/stzStringEncoder.ring"
    load "string/stzStringNumbers.ring"
    load "string/stzStringDuplicates.ring"
    load "string/stzStringCode.ring"
    load "string/stzStringIO.ring"
    load "string/stzStringRandomizer.ring"
    load "string/stzStringLocale.ring"
    load "string/stzStringCrypto.ring"

    load "string/stzStringRemover.ring"
    load "string/stzStringInserter.ring"
    load "string/stzStringCounter.ring"
    load "string/stzStringSections.ring"
    load "string/stzStringGetter.ring"
    load "string/stzStringExtractor.ring"
    load "string/stzStringTrimmer.ring"
    load "string/stzStringComparator.ring"
    load "string/stzStringLeadTrail.ring"
    load "string/stzStringPerformer.ring"
    load "string/stzStringConcat.ring"
    load "string/stzStringCaseChanger.ring"
    load "string/stzStringAligner.ring"
    load "string/stzTextStream.ring"

# Loading files related to REGEX module

    load "regex/stzRegex.ring"
    load "regex/stzRegexMaker.ring"
    load "regex/stzListex.ring"
    load "regex/stzNumbrex.ring"
    load "regex/stzTimex.ring"
    load "regex/stzMatrex.ring"
    load "regex/stzTablex.ring"
    load "regex/stzGraphex.ring"

    load "regex/stzListexUter.ring"
    load "regex/stzRegexUter.ring"

# Loading files related to the LIST module

    load "list/stzHashList.ring"
    load "list/stzItem.ring"
    load "list/stzList.ring"
    load "list/stzDeepList.ring"
    load "list/stzListInString.ring"

    load "list/stzListOfHashLists.ring"
    load "list/stzListOfLists.ring"
    load "list/stzListOfPairs.ring"
    load "list/stzListOfSections.ring"

    load "list/stzListOfSets.ring"
    load "list/stzListPaths.ring"
    load "list/stzListShow.ring"
    load "list/stzPair.ring"

    load "list/stzPairOfLists.ring"
    load "list/stzSection.ring"
    load "list/stzSet.ring"
    load "list/stzSetOfSections.ring"

# Loading files related to the TABLE module

    load "table/stzTable.ring"

    load "table/stzTableFinder.ring"
    load "table/stzTableColumnAccess.ring"
    load "table/stzTableRowAccess.ring"
    load "table/stzTableCellAccess.ring"
    load "table/stzTableSearch.ring"
    load "table/stzTableReplacer.ring"
    load "table/stzTableStructure.ring"
    load "table/stzTableSubset.ring"
    load "table/stzTableSorter.ring"
    load "table/stzTableAggregator.ring"
    load "table/stzTableDisplay.ring"

    load "table/stzListOfTables.ring"

    load "list/stzGrid.ring"
    load "list/stzList2D.ring"
    load "list/stzListOfGrids.ring"
    load "list/stzListParser.ring"
    load "list/stzListProvidedAsString.ring"
    load "table/stzPivotTable.ring"
    load "table/stzPivotTableShow.ring"
    load "list/stzSortedList.ring"
    load "list/stzTile.ring"
    load "list/stzTree.ring"

    # List global functions and Q-constructors

    load "list/stzListFunc.ring"

    # Modular subclasses (domain modules — base layer)

    load "list/stzListFinder.ring"
    load "list/stzListReplacer.ring"
    load "list/stzListRemover.ring"
    load "list/stzListInserter.ring"
    load "list/stzListSorter.ring"
    load "list/stzListWalker.ring"
    load "list/stzListChecker.ring"
    load "list/stzListDuplicates.ring"
    load "list/stzListBounder.ring"
    load "list/stzListFlattener.ring"
    load "list/stzListCounter.ring"
    load "list/stzListSections.ring"
    load "list/stzListRandom.ring"
    load "list/stzListSplits.ring"
    load "list/stzListStringify.ring"
    load "list/stzListNamedParams.ring"
    load "list/stzListGetter.ring"
    load "list/stzListExtractor.ring"
    load "list/stzListTrimmer.ring"
    load "list/stzListMover.ring"
    load "list/stzListClassifier.ring"
    load "list/stzListComparator.ring"
    load "list/stzListLeadTrail.ring"
    load "list/stzListPerformer.ring"
    load "list/stzListMerger.ring"

# Loading files related to the GRAPH module

    load "graph/stzGraph.ring"
    load "graph/stzGraphRule.ring"
    # stzCodeRule IS-A stzGraphRule, so it loads AFTER it -- though it lives in
    # meta/ (StzCheckCode, in meta/stzCodeRules.ring, builds it only at runtime).
    load "graph/stzRuleReport.ring"
    load "meta/stzCodeRule.ring"

    load "graph/stzGraphQuery.ring"
    load "graph/stzGraphView.ring"

    load "graph/stzGraphPlanner.ring"
    load "graph/stzGraphGoal.ring"
    load "graph/stzKnowledgeGraph.ring"

    load "graph/stzDiagram.ring"
    load "graph/stzDiagramColor.ring"

    load "graph/stzOrgChart.ring"
    # org-governance rules over the org chart's graph projection (phase 2b):
    # the compliance bases carry these -- loaded after stzOrgChart (its bases
    # call the loaders at runtime)
    load "graph/stzOrgRule.ring"

    load "graph/stzWorkflow.ring"

    # BPMN drawing, straight to SVG -- the first renderer here that needs no
    # graphviz. Implements the versioned BPMN layout law; see the file header.
    load "graph/stzBpmnDiagram.ring"

# Loading files related to the ENGINE WRAPPER modules

    load "common/stzStateMachine.ring"
    load "common/stzValidator.ring"
    load "common/stzCache.ring"
    load "common/stzConstraint.ring"
    load "number/stzSequence.ring"
    load "common/stzRelation.ring"
    load "number/stzSimilarity.ring"
    load "common/stzEngineTimeline.ring"
    load "common/stzCancelToken.ring"
    load "common/stzRetryBudget.ring"
    load "common/stzLatencyHistogram.ring"
    load "common/stzRateLimiter.ring"
    # structured, queryable, leveled logging (observability infra)
    load "common/stzLog.ring"
    # stzRequestSigner moved to base/security/ (HMAC request signing is a
    # security primitive); loaded in the security block.
    load "common/stzTraceContext.ring"
    load "graph/stzGridNav.ring"

# Loading files related to the VISUAL module

    #TODO// Put here all visual-oriented functions and classes

# Loading files related to SYSTEM module

    # NOTE: stzProfiler.ring (a self-instrumenting-function demo script,
    # never loadable) retired to base/archive/system/ -- superseded by the
    # perf module (base/perf/, SOFTANZA_PERF_SYSTEM.md P0).
    load "system/stzSystemCall.ring"

    load "system/stzMemoryGlobals.ring"
    load "system/stzMemoryConvertors.ring"

    # System Foundation: engine-backed process/environment facts.
    # stzProcess loads BEFORE stzOperatingSystem, which now delegates its
    # architecture / bit-size / endianness facts to it (one engine source).
    load "system/stzProcess.ring"
    load "system/stzEnvironment.ring"

    load "system/stzOperatingSystem.ring"

    # Scope-model floor (Phase 1b): stzSystemProfile is the named SCOPE the
    # programmer writes system code in (development / runtime / deployment),
    # with the capability envelope as the keystone. Loads AFTER the three
    # classes above -- DevelopmentSystem() composes their live facts.
    load "system/stzSystemProfile.ring"

    # Phase 4 (the governance crossing): a stzSystemActor carries capability
    # KINDS (effectful/sensing/compute/inference) -- the authority axis of the
    # scope model. It gates whether an UpdatePlan may commit. Loaded before the
    # twin so the plan can hold an executor.
    load "system/stzSystemActor.ring"

# Loading files related to the SERVICE-VIRTUALIZATION plane (base/service/)
    # Code against a duck-typed SERVICE PORT bound to a fee-free sandbox in dev and
    # a live adapter at deploy. The mail port (Send(to,subject,body)) is the first
    # piece -- passwordless auth below uses it (captured + assertable in dev, really
    # sent in production; same code, no fees).
    load "service/stzServiceRegistry.ring" # the ONE place external deps are declared
    load "service/stzServiceRule.ring"  # the constraint rules (delivery x registry)
    load "service/stzBlobPort.ring"     # the OBJECT-STORE port (local-real: a directory)
    load "service/stzLlmPort.ring"      # the generative port (replay/scripted/local)
    load "service/stzPaymentsPort.ring" # the payments port (deterministic gateway)
    load "service/stzHttpPort.ring"   # the generic HTTP port (scripted + replay)
    load "service/stzDataPort.ring"   # the DATABASE port (local-real: sqlite)
    load "service/stzMailPort.ring"
    load "service/stzSmsPort.ring"      # the SMS port (a sink that counts SEGMENTS)
    load "service/stzOidcSandbox.ring"   # a fee-free IDENTITY PROVIDER double
    load "service/stzPasskeySandbox.ring" # a virtual AUTHENTICATOR (device double)

# Loading files related to the SECURITY module (base/security/)
    # The library's security concern, consolidated: confidential data +
    # credentials (stzSecret + its kinds), a central project keyring that governs
    # and audits their use (stzSecretStore), and user authentication (stzAuth).
    # A secret reveals its value only to an effectful, non-sandboxed actor -- the
    # same governance crossing as stzSystemActor above, which this module is loaded
    # right after (it is the authority these classes are gated by).
    load "security/stzCryptoFuncs.ring"
    load "security/stzSecret.ring"
    load "security/stzVaultResolver.ring"
    load "security/stzSecretStore.ring"
    load "security/stzAuthStore.ring"   # the persistence seam stzAuth defaults to
    load "security/stzTotp.ring"        # RFC 6238 second factor (used by stzAuth 2FA)
    load "security/stzOidc.ring"        # JWT verification + the OIDC relying party
    load "security/stzPasskey.ring"     # WebAuthn / passkeys (the relying party)
    load "security/stzOidcProvider.ring" # Softanza AS an identity provider
    load "security/stzSaml.ring"        # SAML 2.0 SSO (the service-provider side)
    load "security/stzSamlProvider.ring" # Softanza AS a SAML identity provider
    load "security/stzAuth.ring"
    load "security/stzRequestSigner.ring"
    load "security/stzSecurityPosture.ring"
    # the security surface as an explicit GRAPH + rules that see PATHS, not just
    # flags (stzSecurityRule IS-A stzGraphRule) -- multi-hop escalation
    load "security/stzSecurityGraph.ring"
    load "security/stzSecurityRule.ring"
    # incident analysis (SOFTANZA_INCIDENT_ANALYSIS.md) -- I0: the typed
    # security event. "A refusal is an event, not a silent failure":
    # the closed kind catalog, both clocks, the trace id of the active
    # scope, and the REDACTION LAW (subjects are descriptors, never
    # values) enforced at construction.
    load "security/stzSecurityEvent.ring"
    # I1: the ledger -- bounded, hash-chained memory for those events
    # (engine/src/seclog.zig). Evidence, not logging: an edit breaks
    # the chain and Verify() names the link; SealTo() exports a keyed,
    # re-verifiable file, because evidence-grade means exported.
    load "security/stzSecurityLedger.ring"
    # I3: detection over SEQUENCES -- burst / sequence / any-occurrence
    # over the ledger's events. Every other rule in the library judges
    # structure at ONE INSTANT; an incident is a story. Verdicts are
    # findings in the unified shape, so they join the ONE CI gate.
    load "security/stzDetection.ring"
    # I4: the sentinel -- detections on a cadence, edge-triggered (a
    # standing attack is one story, not one per second), event-bus
    # fanout, hostable on any stzAgentHost, and a case snapshot
    # photographed at the moment of firing.
    load "security/stzSecuritySentinel.ring"
    # I5: the incident -- a sentinel's case correlated into the file a
    # person reads: timeline, actors, subjects, the attack PATH from
    # the security graph, the blast radius of any secret involved, and
    # a forward-only status (open -> contained -> closed).
    load "security/stzIncident.ring"
    # I6: the response -- containment as a GOVERNED act. A closed
    # catalog of verbs, MayCommit() preflight, execution gated on an
    # effectful non-sandboxed actor, every outcome audited AND
    # recorded in the ledger. The machine proposes; only an effectful
    # actor commits.
    load "security/stzResponsePlan.ring"
    # I7: attestation -- the custody statement over a sealed ledger.
    # Exporting the evidence is a SENSING act (the ledger is itself
    # sensitive), so an inference-only actor may analyze in-process
    # and may not write the file out.
    load "security/stzSecurityAttestation.ring"
    # I8: the drill -- adversary emulation against a REAL spawned app,
    # with the evidence crossing the process boundary as a sealed file
    # the parent must verify before it may believe it. A detection
    # nobody has ever seen fire is a hypothesis.
    load "security/stzSecurityDrill.ring"

    # Virtual System twin (Phase 2): rehearse file operations in an in-memory
    # tree, generate a narrated UpdatePlan, and commit through the ONE bridge
    # (engine file primitives). The twin holds no reference to reality; disk
    # changes only on Execute(). Core loads before the file specialization.
    load "system/stzVirtualSystem.ring"
    load "system/stzVirtualFileSystem.ring"

    # Phase 3: the Process/Environment twin -- rehearse env-var changes, a cwd
    # change, and a queue of process spawns; commit atomically through the one
    # bridge (stzEnvironment's effectful verbs + SpawnProcess). Same core.
    load "system/stzVirtualEnvironment.ring"

    # Phase 3b: the FULL scope model -- the architect's common ground. A
    # stzPlatformProfile holds the dev system + the apps; each app deploys to a
    # stzSystemProfile; feature code is written in App(:x).System() scopes that
    # down-constrain (refuse what the target forbids) and up-enable (rehearse
    # what the host lacks). Loads last -- it composes everything above.
    load "system/stzPlatformProfile.ring"

    # stzBuilder: softanzifies the BUILD. Zig's `cc` cross-compiles C/C++ to any
    # target with one -target flag; stzBuilder wraps it declaratively and derives
    # the target triple from a stzSystemProfile (a deployment system). It runs the
    # build through the engine-backed managed child (SpawnProcess). Loads after
    # the profile (For(target) reuses _StzSystemProfileForTarget).
    load "system/stzBuilder.ring"
    load "system/stzWebBundle.ring"
    # the solution's APP MODEL -- named datasets + per-part roles; the dashboard
    # role aggregates via the engine. Drives per-part emulator rendering (held by
    # the delivery, read by the emulator).
    load "system/stzAppTopology.ring"
    load "system/stzDelivery.ring"
    load "system/stzEmulator.ring"

    # stzDeployment: the deployment story end to end -- a stzDeploymentSite is a
    # config-described target repo (connection/storage/protocol/control); a
    # stzDeployment binds each part to a site and stores/launches/reports, GOVERNED
    # (only an effectful actor commits). Deploy(:Emulated) rehearses; this commits.
    load "system/stzDeployment.ring"

    load "system/stzMemoryProfiler.ring"
    load "system/stzMemoryProfiler32Bit.ring"
    load "system/stzMemoryProfiler64Bit.ring"

    load "system/stzProfilingTimer.ring"

    load "system/stzPointer.ring"

    load "system/stzUUID.ring"     # Engine-backed UUID v4 (Zig)

# Loading files related to the PERF module (base/perf/) -- the
# performance system (SOFTANZA_PERF_SYSTEM.md). P0: the honest
# stopwatch -- numeric, monotonic (engine watch clock), unlimited
# instances, OTel-span exportable. P1: the engine senses (stz_perf.dll:
# RSS/peak, system memory, CPU time) + the engine-resident metric series.

# P2: metrics and the monitor -- stzMetric (:Counter/:Gauge/:Timer
# faces over the engine series + histogram; ALL state engine-side, so
# Ring copies share one truth) + stzPerfMonitor (the sampler: pull /
# tick / hosted-as-agent; Prometheus exposition + OTLP export).

# P4: judgment -- stzSla (expectations in the U/R/X/D vocabulary;
# verdicts = findings in the unified rule shape, subject "perf", so a
# perf budget joins stzRuleReport, the ONE CI gate) + stzPerfSentinel
# (edge-triggered alerts on a cadence; event-bus fanout; hostable).

    load "perf/stzStopwatch.ring"
    load "perf/stzPerfSeries.ring"
    load "perf/stzMetric.ring"
# P8: labels/dimensions -- stzMetricFamily: one name + label names,
# one CHILD per label-value set; the child registry lives ENGINE-side
# (copies share it); cardinality bounded with an explicit overflow
# child; label-aware Prometheus/OTLP exposition.
    load "perf/stzMetricFamily.ring"
    load "perf/stzPerfMonitor.ring"
    load "perf/stzSla.ring"
    load "perf/stzPerfSentinel.ring"
# P5: understanding -- stzPerfProfile: interval-anchored operational
# analysis (U/R/X/D, service demand, bottleneck = the computing/waiting
# split, Little's-law + utilization-law self-checks, memory forecast,
# R-vs-X curve, the narrated Explain()).
    load "perf/stzPerfProfile.ring"
# P6: the governed loop -- stzPerfPlan: optimization as a governed act
# (a closed catalog of effectful verbs; an inference-only actor may
# BUILD the plan, only an effectful one commits; full audit). Plus:
# Profile.Load() -> supervisor FeedLoadFrom (measured scaling signal),
# Monitor.SelfCost() (observation prices itself), Sentinel black box
# (the flight recorder written AT breach time).
    load "perf/stzPerfPlan.ring"
# P7 (the tail): request tracing (engine trace ring; the black box
# carries the trip's trace ids) + stzOtelBatch (the OTLP resourceSpans
# envelope -- many spans, one shipment).
    load "perf/stzOtelBatch.ring"
# P9: log-trace correlation -- the TRACE SCOPE (engine-global active
# traceparent): the observed server opens it per request; every stzLog
# record inside a scope stamps the trace id; stzLog.OfTrace() queries
# by it and OtelJson() ships the OTLP logs envelope (the OTel triad
# complete: spans, metrics, logs).
    load "perf/stzTraceScope.ring"
# P10: the frame profiler -- WHERE the time goes: cooperative frames,
# engine-side call tree (self vs total), a REAL sampler thread
# photographing the active path, folded-stacks flame-graph export.
# (The stzProfiler name is the P0 fossil's, resurrected on the engine.)
    load "perf/stzProfiler.ring"
# P11: the driven-load harness -- real concurrent arrivals via real
# driver PROCESSES against a spawned target server: the R-vs-X curve
# and its knee, measured from the client side (queue wait included).
    load "perf/stzLoadDriver.ring"

# Loading files related to the FILE module

    load "file/stzFile.ring"
    load "file/stzZipFile.ring"

    load "file/stzFolder.ring"

    load "file/stzJson.ring"
    load "file/stzXmlFuncs.ring"
    load "file/stzXml.ring"
    load "file/stzCSV.ring"
    load "file/stzHtml.ring"     # Engine-backed HTML parser (Zig)

    load "file/stzFolderWatcher.ring"  # Engine-backed folder watcher (Zig)

# Loading the YIELDER module (functional map/filter/reduce)

    load "list/stzYielder.ring"

# Loading files related to the ERROR module

    load "error/stzObjectError.ring"
    load "error/stzStringError.ring"

    load "error/stzCounterError.ring"
    load "error/stzFileError.ring"

    load "error/stzListError.ring"
    load "error/stzListOfBytesError.ring"
    load "error/stzListOfStringsError.ring"

    load "error/stzNumberError.ring"
    load "error/stzBinaryNumberError.ring"
    load "error/stzHexNumberError.ring"
    load "error/stzOctalNumberError.ring"
    load "error/stzDecimalToBinaryError.ring"

    load "error/stzCountryError.ring"
    load "error/stzError.ring"

# Loading files related to the DATETIME module

    load "datetime/stzDate.ring"
    load "datetime/stzTime.ring"
    load "datetime/stzDateTime.ring"
    load "datetime/stzDuration.ring"
    load "datetime/stzTimeLine.ring"
    load "datetime/stzCalendar.ring"

    load "datetime/stzListOfTimeLines.ring"

# Loading files related to the I18N module

    load "i18n/stzCountry.ring"
    load "i18n/stzCurrency.ring"
    load "i18n/stzLanguage.ring"
    load "i18n/stzLocale.ring"
    load "i18n/stzScript.ring"

# Loading files related to the EXTINCODE module

    load "extincode/stzExtinCode.ring"
    load "extincode/stzExtinCSharp.ring"
    load "extincode/stzExtinPython.ring"
    load "extincode/stzExtinJS.ring"
    load "extincode/stzExtinSql.ring"
    load "extincode/stzExtinPerl.ring"
    load "extincode/stzExtinC.ring"

# Loading files related to the EXERCODE module

    load "extercode/stzExterCode.ring"
    load "extercode/stzPythonCode.ring"
    load "extercode/stzRCode.ring"
    load "extercode/stzJuliaCode.ring"
    load "extercode/stzPrologCode.ring"

    load "extercode/stzDotCode.ring"
    load "extercode/stzQmlCode.ring"

# Loading files related to the NETWORK module

    load "network/stzNetwork.ring"
    load "network/stzHttpClient.ring"
    load "network/stzWebSocket.ring"
    load "network/stzTcpClient.ring"
    load "network/stzTcpServer.ring"
    load "network/stzNetworkUtils.ring"

# Loading files related to the REACTIVE module

    load "reactive/stzReactiveGlobals.ring"
    load "reactive/stzReactive.ring"
    load "reactive/stzReactiveTask.ring"

    load "reactive/stzReactiveFunc.ring"
    load "reactive/stzReactiveObject.ring"

    load "reactive/stzReactiveTimer.ring"
    load "reactive/stzReactiveStream.ring"
    load "reactive/stzReactiveHttp.ring"

    # stzReactor / stzReactorPool -- the vendored-libuv reactor surface
    # (real async; the declarative Reaxis surface above is being re-based
    # onto this -- see the R7 reactive-substrate work)
    load "reactive/stzReactor.ring"
    load "reactive/stzReactorPool.ring"
    load "reactive/stzEventBus.ring"

# Loading files related to APPSERVER module (FUTURE)

    load "app/stzApp.ring"
    load "app/stzSuperApp.ring"


    load "appserver/stzAppServer.ring"
    load "appserver/stzAppRequest.ring"
    load "appserver/stzAppResponse.ring"
    load "appserver/stzAppRouter.ring"
    # the LIVE backend: an stzAppTopology's parts sharing one real state
    # (loaded last -- it needs stzDatabase, stzAppTopology AND stzAppServer)
    load "appserver/stzAppBackend.ring"

# cluster/ -- THE SCALE PLANE (R8): the delivery plane's horizontal
# axis. Specialization is a WORKER PROFILE (capability tag + resource
# budget) over the ONE resident engine, NOT a preloading class tree
# (5.10 ruling; section 7). R8.1 = the worker model. The pre-engine
# stzCluster* prototype it replaced is DELETED, not kept as tombstones:
# superseded code that still loads is still debt (it carried its own
# conventions, its own tests, and a second answer to a settled question).

    load "cluster/stzWorkerProfile.ring"
    load "cluster/stzFacetCatalog.ring"
    load "cluster/stzWorkerPool.ring"
    load "cluster/stzClusterTelemetry.ring"
    load "cluster/stzAppCluster.ring"
    load "cluster/stzClusterSupervisor.ring"
    load "cluster/stzComputePipeline.ring"
    load "cluster/stzComputeFederation.ring"

    load "cluster/stzRequestClassifier.ring"

# cluster/ -- THE DISTRIBUTION PLANE (D-phases): message-passing nodes
# over the STZM wire fixed by D0 (SOFTANZA_DISTRIBUTION_PLAN.md).

    load "cluster/stzNode.ring"
    load "cluster/stzNodePlane.ring"
    load "cluster/stzNodeSupervisor.ring"
    load "cluster/stzNodeApp.ring"
    load "cluster/stzNetCalibrate.ring"

# Loading files related to NATURAL module

    load "natural/stzChainOfTruth.ring"
    load "natural/stzChainOfValue.ring"

    load "natural/stzEntity.ring"
    load "natural/stzListOfEntities.ring"
    load "natural/stzKnowledgeWorld.ring"

    load "natural/stzNaturalCode.ring"
    load "natural/stzNNL.ring"
    load "natural/stzQuestion.ring"
    load "natural/stzConstraints.ring"
    load "natural/stzTruthChain.ring"
    load "natural/stzSemanticResolver.ring"
    load "natural/stzNatural.ring"
    load "natural/stzNaturalLangData.ring"

    # conversation/ -- CONVERSATIONAL PROGRAMMING as a domain (R3b):
    # stzConversation (entry) runs the wise-coding loop over the R1
    # knowledge graph; stzGoal generates questions from gaps;
    # stzNarration is the system's side of the dialogue.
    load "conversation/stzNarration.ring"
    load "conversation/stzGoal.ring"
    load "conversation/stzConversation.ring"

    # learning/ -- MODEL CREATION as a domain (R4, step 0: the classic
    # ML floor -- zero-setup, fully explainable learners riding
    # stzTrainingSet + stzSimilarity + the linguistic domain).
    load "learning/stzTrainingSet.ring"
    load "learning/stzKnn.ring"
    load "learning/stzNaiveBayes.ring"
    load "learning/stzDecisionTree.ring"
    load "learning/stzApriori.ring"
    load "learning/stzKMeans.ring"
    load "learning/stzLogisticRegression.ring"
    load "learning/stzModelEval.ring"
    load "learning/stzNeuralNetwork.ring"
    load "learning/stzTrainer.ring"
    load "learning/stzDLM.ring"

    # governance/ -- PROGRAMMATIC GOVERNANCE as declarable contracts
    # (R4b): risk tiers, permission-vs-authority, commitment states,
    # decommission contracts, decision lineage, trust postures.
    load "governance/stzGovernance.ring"

    # platform/ -- THE OPERATIONAL ENVELOPE (5.10, R7): stzPlatform =
    # generation (Reach -> shells), the governance-gated capability
    # seam, the Commons runtime (identity/messaging/stores over
    # sqlite), the networked body (world served via the reactor host),
    # and the world registry with norm-enforced cross-world calls.
    load "platform/stzPlatform.ring"

    # agentic/ -- THE CONVERGENCE (R5): the PI-agent assembled from the
    # roadmap's parts -- skills (precondition+plan+verification),
    # memory (knowledge graph), governance gate (R4b), the
    # perceive-decide-act cycle to fixpoint.
    load "agentic/stzAgentSkill.ring"
    load "agentic/stzAgentMemory.ring"
    load "agentic/stzPIAgent.ring"
    load "agentic/stzAgentGraph.ring"
    # the four guardrails as declared rules (stzAgentRule IS-A stzGraphRule) +
    # the effects-dominated strengthening -- loaded after stzAgentGraph
    load "agentic/stzAgentRule.ring"
    load "agentic/stzLLMAgent.ring"
    load "agentic/stzOwnAgentStack.ring"
    load "agentic/stzAgentHost.ring"
    # agents as FILES: the .pia declaration, its court, and the folder
    # convention. A front-end onto the classes above -- no new runtime.
    load "agentic/stzAgentDeclaration.ring"
    load "agentic/stzAgentFolder.ring"
    # the roster: the estate's own PowerShell mechanisms as ring:
    # functions behind softanza/roster/*.pia (prompt 46). A front-end
    # onto the classes above, same as the two files just loaded.
    load "agentic/stzAgentRoster.ring"

    # refine/ -- REFINEMENT PROGRAMMING (R6): stzPolyCode comes home --
    # code carries typed refinement points; a change is a typed proposal
    # through the gate, with cascade preview + reversibility.
    load "refine/stzRefinableCode.ring"

    load "linguistic/stzAdverb.ring"
    load "linguistic/stzPlural.ring"
    load "linguistic/stzSingular.ring"
    load "linguistic/stzOrdinal.ring"

# Loading files related to STATS module

    load "stats/stzDataSet.ring"
    load "stats/stzBarPlot.ring"
    load "stats/stzHBarPlot.ring"
    load "stats/stzMBarPlot.ring"
    load "stats/stzSurfacePlot.ring"
    load "stats/stzScatterPlot.ring"
    load "stats/stzHistogram.ring"
    load "stats/stzHypothesis.ring"
    load "stats/stzDataWrangler.ring"
    load "stats/stzCoeffExtractor.ring"
    load "stats/stzLinearSolver.ring"
    load "stats/stzMultiObjectiveSolver.ring"
    load "stats/stzStochasticSolver.ring"

// tz1 = clock()
// ? "Softanza laoding time:"
// ? (tz1 - tz0) / clockspersecond() + NL
