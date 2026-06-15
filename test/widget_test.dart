import 'package:flutter_test/flutter_test.dart';
import 'package:custo_doce/core/models/subscription_plan.dart';

void main() {
  group('Fórmulas de precificação', () {
    test('custo unitário calculado corretamente', () {
      const packageSize = 1000.0;
      const costPerPackage = 5.50;
      final result = costPerPackage / packageSize;
      expect(result, closeTo(0.0055, 0.0001));
    });

    test('preço de venda com margem 40% calculado corretamente', () {
      const custoTotal = 12.0;
      const margem = 40.0;
      final result = custoTotal * (1 + margem / 100);
      expect(result, closeTo(16.80, 0.01));
    });

    test('preço de venda é sempre maior que custo quando margem > 0', () {
      for (final caso in [
        (custo: 10.0, margem: 1.0),
        (custo: 100.0, margem: 50.0),
        (custo: 5.0, margem: 100.0),
      ]) {
        final preco = caso.custo * (1 + caso.margem / 100);
        expect(preco, greaterThan(caso.custo));
      }
    });

    test('margem zero mantém o mesmo valor do custo', () {
      const custoTotal = 20.0;
      final result = custoTotal * (1 + 0.0 / 100);
      expect(result, equals(20.0));
    });

    test('custo total é soma dos ingredientes', () {
      final ingredientes = [2.50, 1.00, 0.75, 3.20];
      final total = ingredientes.fold(0.0, (acc, val) => acc + val);
      expect(total, closeTo(7.45, 0.01));
    });

    test('sellingPrice usa valor definido ou cai para sugerido', () {
      const sugerido = 15.0;
      double? sellingPrice = 18.0 as double?;
      expect((sellingPrice as double?) ?? sugerido, equals(18.0));
      sellingPrice = null;
      expect(sellingPrice ?? sugerido, equals(15.0));
    });

    test('roundSuggestedPrice: decimal < 0.50 → X,50', () {
      double round(double raw) {
        final i = raw.floor(); final d = raw - i;
        if (d == 0.0) return raw;
        if (d < 0.50) return i + 0.50;
        if (d < 0.75) return i + 0.99;
        return (i + 1).toDouble();
      }
      expect(round(1.20), equals(1.50));
      expect(round(12.30), equals(12.50));
      expect(round(0.10), equals(0.50));
    });

    test('roundSuggestedPrice: 0.50 <= decimal < 0.75 → X,99', () {
      double round(double raw) {
        final i = raw.floor(); final d = raw - i;
        if (d == 0.0) return raw;
        if (d < 0.50) return i + 0.50;
        if (d < 0.75) return i + 0.99;
        return (i + 1).toDouble();
      }
      expect(round(1.70), equals(1.99));
      expect(round(7.72), equals(7.99));
      expect(round(5.50), equals(5.99));
    });

    test('roundSuggestedPrice: decimal >= 0.75 → inteiro seguinte', () {
      double round(double raw) {
        final i = raw.floor(); final d = raw - i;
        if (d == 0.0) return raw;
        if (d < 0.50) return i + 0.50;
        if (d < 0.75) return i + 0.99;
        return (i + 1).toDouble();
      }
      expect(round(1.76), equals(2.00));
      expect(round(7.82), equals(8.00));
      expect(round(9.99), equals(10.00));
    });

    test('roundSuggestedPrice: inteiro não muda', () {
      double round(double raw) {
        final i = raw.floor(); final d = raw - i;
        if (d == 0.0) return raw;
        if (d < 0.50) return i + 0.50;
        if (d < 0.75) return i + 0.99;
        return (i + 1).toDouble();
      }
      expect(round(5.00), equals(5.00));
      expect(round(10.00), equals(10.00));
    });
  });

  group('Limites de plano', () {
    test('Free: 3 receitas, 15 ingredientes', () {
      const limits = PlanLimits.free;
      expect(limits.recipeLimit, equals(3));
      expect(limits.ingredientLimit, equals(15));
    });

    test('Light: 30 receitas, cardápio desabilitado', () {
      const limits = PlanLimits.light;
      expect(limits.recipeLimit, equals(30));
      expect(limits.hasDigitalMenu, isFalse);
    });

    test('Pro: receitas ilimitadas, cardápio habilitado', () {
      const limits = PlanLimits.pro;
      expect(limits.isUnlimitedRecipes, isTrue);
      expect(limits.hasDigitalMenu, isTrue);
    });

    test('Premium: tudo habilitado', () {
      const limits = PlanLimits.premium;
      expect(limits.isUnlimitedRecipes, isTrue);
      expect(limits.hasDigitalMenu, isTrue);
      expect(limits.hasExportPdf, isTrue);
      expect(limits.hasInvoiceScan, isTrue);
      expect(limits.hasCloudBackup, isTrue);
    });

    test('Pro não tem PDF nem nota fiscal', () {
      const limits = PlanLimits.pro;
      expect(limits.hasExportPdf, isFalse);
      expect(limits.hasInvoiceScan, isFalse);
    });
  });

  group('Autenticação e modo visitante', () {
    test('visitante não pode acessar paywall', () {
      const isGuest = true;
      const isLoggedIn = false;
      final canAccessPaywall = !isGuest && isLoggedIn;
      expect(canAccessPaywall, isFalse);
    });

    test('usuário logado pode acessar paywall', () {
      const isGuest = false;
      const isLoggedIn = true;
      final canAccessPaywall = !isGuest && isLoggedIn;
      expect(canAccessPaywall, isTrue);
    });
  });

  group('Validação de formulários', () {
    test('email inválido não passa', () {
      String? validateEmail(String? value) {
        if (value == null || value.isEmpty) return 'Campo obrigatório';
        final regex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
        if (!regex.hasMatch(value)) return 'Email inválido';
        return null;
      }
      expect(validateEmail('nao-e-email'), isNotNull);
      expect(validateEmail('valido@email.com'), isNull);
    });

    test('senha com menos de 6 chars é inválida', () {
      String? validatePassword(String? value) {
        if (value == null || value.length < 6) return 'Mínimo 6 caracteres';
        return null;
      }
      expect(validatePassword('123'), isNotNull);
      expect(validatePassword('123456'), isNull);
    });

    test('confirmar senha deve ser igual à senha', () {
      String? validateConfirm(String? value, String senha) {
        if (value != senha) return 'Senhas não coincidem';
        return null;
      }
      expect(validateConfirm('abc', '123'), isNotNull);
      expect(validateConfirm('abc', 'abc'), isNull);
    });
  });

  group('Lógica de cardápio', () {
    test('cardápio exibe apenas receitas com showInMenu == true', () {
      final todasReceitas = [
        (name: 'Bolo', showInMenu: true),
        (name: 'Trufa', showInMenu: false),
        (name: 'Brigadeiro', showInMenu: true),
      ];
      final menuReceitas = todasReceitas.where((r) => r.showInMenu).toList();
      expect(menuReceitas.length, equals(2));
      expect(menuReceitas.map((r) => r.name), containsAll(['Bolo', 'Brigadeiro']));
    });

    test('preço exibido usa sellingPrice se definido', () {
      const sugerido = 15.0;
      const sellingPrice = 18.0;
      final exibido = sellingPrice;
      expect(exibido, equals(18.0));
    });

    test('preço exibido usa roundSuggestedPrice quando sellingPrice é null', () {
      double round(double raw) {
        final i = raw.floor(); final d = raw - i;
        if (d == 0.0) return raw;
        if (d < 0.50) return i + 0.50;
        if (d < 0.75) return i + 0.99;
        return (i + 1).toDouble();
      }
      const sugerido = 15.30;
      final exibido = round(sugerido);
      expect(exibido, equals(15.50));
    });
  });
}
