library globals;

import 'package:Dokusho/models/persisted_model.dart';
import 'package:providerscope/providerscope.dart';

final Providers providers = Providers()
    ..provideValue(PersistedModel());