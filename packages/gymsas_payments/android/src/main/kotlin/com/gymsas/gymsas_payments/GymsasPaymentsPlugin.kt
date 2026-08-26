package com.gymsas.gymsas_payments

import android.app.Activity
import android.content.Context
import com.mercadopago.sdk.android.checkout.core.MercadoPagoCheckout
import com.mercadopago.sdk.android.checkout.core.model.MPCheckoutType
import com.mercadopago.sdk.android.checkout.core.model.MPOrder
import com.mercadopago.sdk.android.checkout.domain.callback.MercadoPagoCheckoutResult
import com.mercadopago.sdk.android.domain.model.CountryCode
import com.mercadopago.sdk.android.initializer.MercadoPagoSDK
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class GymsasPaymentsPlugin : FlutterPlugin, ActivityAware, MethodChannel.MethodCallHandler {
    private lateinit var channel: MethodChannel
    private lateinit var applicationContext: Context
    private var activity: Activity? = null
    private var pendingResult: MethodChannel.Result? = null

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        applicationContext = binding.applicationContext
        channel = MethodChannel(binding.binaryMessenger, "gymsas/payments")
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        if (call.method != "checkout") {
            result.notImplemented()
            return
        }
        val currentActivity = activity
        if (currentActivity == null) {
            result.error("activity_unavailable", "No hay una Activity disponible", null)
            return
        }
        if (pendingResult != null) {
            result.error("checkout_in_progress", "Ya existe un checkout en curso", null)
            return
        }
        val publicKey = call.argument<String>("publicKey").orEmpty()
        val orderId = call.argument<String>("orderId").orEmpty()
        val clientToken = call.argument<String>("clientToken").orEmpty()
        if (publicKey.isBlank() || orderId.isBlank() || clientToken.isBlank()) {
            result.error("invalid_arguments", "Faltan datos para abrir el checkout", null)
            return
        }
        pendingResult = result
        try {
            if (!MercadoPagoSDK.isInitialized) {
                MercadoPagoSDK.initialize(applicationContext, publicKey, CountryCode.MEX)
            } else {
                MercadoPagoSDK.setNewConfiguration(publicKey, CountryCode.MEX)
            }
            MercadoPagoCheckout.Builder(
                currentActivity,
                MPCheckoutType.CardTransaction(MPOrder(orderId, clientToken)),
            ).build().show { checkoutResult ->
                val callback = pendingResult ?: return@show
                pendingResult = null
                when (checkoutResult) {
                    is MercadoPagoCheckoutResult.Success -> callback.success(
                        mapOf(
                            "outcome" to "success",
                            "providerStatus" to checkoutResult.paymentData.orderStatus,
                            "paymentMethodId" to checkoutResult.paymentData.paymentMethodId,
                        ),
                    )
                    is MercadoPagoCheckoutResult.UserCancelled -> callback.success(mapOf("outcome" to "cancelled"))
                    is MercadoPagoCheckoutResult.Error -> callback.success(
                        mapOf(
                            "outcome" to "error",
                            "message" to checkoutResult.error.errorMessage,
                            "code" to checkoutResult.error.errorCode.toString(),
                        ),
                    )
                }
            }
        } catch (error: Throwable) {
            pendingResult = null
            result.error("provider_error", error.message, null)
        }
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) { activity = binding.activity }
    override fun onDetachedFromActivityForConfigChanges() { activity = null }
    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) { activity = binding.activity }
    override fun onDetachedFromActivity() { activity = null }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        pendingResult?.error("engine_detached", "El motor Flutter se cerró", null)
        pendingResult = null
    }
}
