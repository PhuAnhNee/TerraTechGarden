import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../pages/ship/home/bloc/ship_bloc.dart';
import '../pages/ship/home/bloc/ship_event.dart';
import '../pages/ship/home/bloc/ship_state.dart';

class ShipDetail extends StatelessWidget {
  final int? userId; // Changed to int? to handle null values

  const ShipDetail({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: BlocProvider.of<ShipBloc>(context),
      child: BlocBuilder<ShipBloc, ShipState>(
        builder: (context, state) {
          if (userId == null) {
            return AlertDialog(
              backgroundColor: const Color(0xFF2a2a2a),
              title: const Text(
                'Error',
                style: TextStyle(color: Colors.white),
              ),
              content: const Text(
                'Invalid user ID',
                style: TextStyle(color: Colors.white),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text(
                    'Close',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ],
            );
          } else if (state is ShipAddressLoaded) {
            return AlertDialog(
              backgroundColor: const Color(0xFF2a2a2a),
              title: const Text(
                'Order Address Details',
                style: TextStyle(color: Colors.white),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Receiver Name: ${state.addressDetails['receiverName']}',
                    style: const TextStyle(color: Colors.white),
                  ),
                  Text(
                    'Receiver Phone: ${state.addressDetails['receiverPhone']}',
                    style: const TextStyle(color: Colors.white),
                  ),
                  Text(
                    'Receiver Address: ${state.addressDetails['receiverAddress']}', // Add this
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text(
                    'Close',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ],
            );
          } else if (state is ShipError) {
            return AlertDialog(
              backgroundColor: const Color(0xFF2a2a2a),
              title: const Text(
                'Error',
                style: TextStyle(color: Colors.white),
              ),
              content: Text(
                state.message,
                style: const TextStyle(color: Colors.white),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text(
                    'Close',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ],
            );
          } else {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (userId != null && !context.read<ShipBloc>().isClosed) {
                context.read<ShipBloc>().add(FetchOrderAddress(userId!));
              }
            });
            return const AlertDialog(
              backgroundColor: Color(0xFF2a2a2a),
              content: Center(child: CircularProgressIndicator()),
            );
          }
        },
      ),
    );
  }
}
