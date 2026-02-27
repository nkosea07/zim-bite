import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/network/api_exception.dart';
import '../data/repositories/order_repository.dart';
import 'orders_event.dart';
import 'orders_state.dart';

class OrdersBloc extends Bloc<OrdersEvent, OrdersState> {
  final OrderRepository _orderRepository;

  OrdersBloc(this._orderRepository) : super(const OrdersInitial()) {
    on<LoadOrders>(_onLoadOrders);
    on<LoadOrderDetail>(_onLoadOrderDetail);
  }

  Future<void> _onLoadOrders(
    LoadOrders event,
    Emitter<OrdersState> emit,
  ) async {
    emit(const OrdersLoading());
    try {
      final orders = await _orderRepository.getOrders();
      emit(OrdersLoaded(orders));
    } on ApiException catch (e) {
      emit(OrdersError(e.message));
    } catch (e) {
      emit(OrdersError(e.toString()));
    }
  }

  Future<void> _onLoadOrderDetail(
    LoadOrderDetail event,
    Emitter<OrdersState> emit,
  ) async {
    emit(const OrdersLoading());
    try {
      final detail = await _orderRepository.getOrder(event.orderId);
      emit(OrderDetailLoaded(detail));
    } on ApiException catch (e) {
      emit(OrdersError(e.message));
    } catch (e) {
      emit(OrdersError(e.toString()));
    }
  }
}
