import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../bloc/ship_bloc.dart';
import '../bloc/ship_event.dart';
import '../bloc/ship_state.dart';
import '../../../../models/transport.dart';
import 'transport_bloc.dart';
import 'transport_detail_dialog.dart';

class TransportCart extends StatelessWidget {
  final String token;

  const TransportCart({Key? key, required this.token}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ShipBloc, ShipState>(
      builder: (context, state) {
        if (state is ShipLoading) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  valueColor:
                      AlwaysStoppedAnimation<Color>(Colors.blue.shade600),
                ),
                SizedBox(height: 16),
                Text(
                  'Loading transports...',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          );
        }

        if (state is ShipError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red.shade400,
                ),
                SizedBox(height: 16),
                Text(
                  'Error',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.red.shade600,
                  ),
                ),
                SizedBox(height: 8),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    state.message,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                    ),
                  ),
                ),
                SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    context
                        .read<ShipBloc>()
                        .add(LoadTransportsEvent(token: token));
                  },
                  icon: Icon(Icons.refresh),
                  label: Text('Retry'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade600,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          );
        }

        if (state is TransportsLoaded) {
          // Filter out completed and failed transports
          final visibleTransports = state.transports
              .where((transport) =>
                  transport.status == 'inWarehouse' ||
                  transport.status == 'shipping')
              .toList();

          if (visibleTransports.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.local_shipping,
                    size: 64,
                    color: Colors.grey.shade400,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No Active Transports',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'There are no transports in warehouse or shipping status.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      context
                          .read<ShipBloc>()
                          .add(LoadTransportsEvent(token: token));
                    },
                    icon: Icon(Icons.refresh),
                    label: Text('Refresh'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade600,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<ShipBloc>().add(LoadTransportsEvent(token: token));
            },
            child: ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: visibleTransports.length,
              itemBuilder: (context, index) {
                final transport = visibleTransports[index];
                final address = state.addresses[transport.orderId];
                return TransportCard(
                  transport: transport,
                  address: address,
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => TransportDetailDialog(
                        transport: transport,
                      ),
                    );
                  },
                  token: token,
                );
              },
            ),
          );
        }

        if (state is TransportUpdated) {
          // When transport is updated, reload the transports list
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.read<ShipBloc>().add(LoadTransportsEvent(token: token));
          });

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  valueColor:
                      AlwaysStoppedAnimation<Color>(Colors.green.shade600),
                ),
                SizedBox(height: 16),
                Text(
                  'Updating transport status...',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          );
        }

        return Center(
          child: Text(
            'Pull to refresh',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 16,
            ),
          ),
        );
      },
    );
  }
}
